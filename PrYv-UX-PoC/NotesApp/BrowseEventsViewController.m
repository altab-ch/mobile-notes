//
//  BrowseEventsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseEventsViewController.h"
#import "BrowseEventsCell.h"
#import "DataService.h"
#import "CellStyleModel.h"
#import "AddNumericalValueViewController.h"
#import "PhotoNoteViewController.h"
#import "SettingsViewController.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "PYEvent+Helper.h"
#import "UIImage+PrYv.h"
#import "PYStream+Helper.h"
#import "MNMPullToRefreshManager.h"
#import "BrowseCell.h"
#import "NoteCell.h"
#import "ValueCell.h"
#import "PictureCell.h"
#import "UnkownCell.h"
#import "NSString+Utils.h"
#import "AppConstants.h"
#import "EventDetailsViewController.h"
#import <PryvApiKit/PYConstants.h>
#import "MCSwipeTableViewCell.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuNavController.h"
#import "PYEventTypes+Helper.h"
#import "XMMDrawerController.h"

#define kPictureToDetailSegue_ID @"kPictureToDetailSegue_ID"
#define kNoteToDetailSegue_ID @"kNoteToDetailSegue_ID"
#define kValueToDetailSegue_ID @"kValueToDetailSegue_ID"

#pragma mark - MySection


@interface MySection : NSObject
@property (nonatomic) NSTimeInterval time;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* key;
@end

@implementation MySection {
    
}
@end

#pragma mark - BrowseEventsVC


#define IS_LRU_SECTION self.isMenuOpen
#define IS_BROWSE_SECTION !self.isMenuOpen

#define kFilterInitialLimit 200
#define kFilterIncrement 30

#define kSectionCell @"section_cell_id"
#define kSectionLabel 10


typedef enum {
    AggregationStepDay = 1,
    AggregationStepMonth,
    AggregationStepYear
} AggregationStep;


static NSString *browseCellIdentifier = @"BrowseEventsCell_ID";

@interface BrowseEventsViewController () <UIActionSheetDelegate,MNMPullToRefreshManagerClient,MCSwipeTableViewCellDelegate>


@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *sectionsMap;
@property (nonatomic, strong) NSMutableOrderedSet *sectionsMapTitles;

@property (nonatomic, strong) NSDateFormatter *sectionsKeyFormatter;
@property (nonatomic, strong) NSDateFormatter *sectionsTitleFormatter;
@property (nonatomic, strong) NSDateFormatter *cellDateFormatter;

@property (nonatomic, strong) NSArray *shortcuts;
@property (nonatomic, strong) MNMPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, strong) PYEvent *eventToShowOnAppear;

@property (nonatomic, strong) PYEventFilter *filter;
@property (nonatomic, strong) UserHistoryEntry *tempEntry;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property (nonatomic) NSTimeInterval *lastTimeFocus;

@property (nonatomic) AggregationStep aggregationStep;

- (void)loadData;
- (void)userDidReceiveAccessTokenNotification:(NSNotification*)notification;
- (void)filterEventUpdate:(NSNotification*)notification;

- (void)resetDateFormatters;
- (void)refreshFilter;
- (void)unsetFilter;
- (MMDrawerController*)mm_drawerController;

@end

@implementation BrowseEventsViewController

BOOL displayNonStandardEvents;

-(MMDrawerController*)mm_drawerController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[MMDrawerController class]]){
            return (MMDrawerController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self togSlider];
}

-(void) toggleSlider{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
}

-(void) togSlider{
    
    MenuNavController* menuNavController = (MenuNavController*)[self.mm_drawerController leftDrawerViewController];
    if ([self.mm_drawerController openSide]==MMDrawerSideLeft) {
        [menuNavController resetMenu];
        
        //[self unsetFilter];
        [self loadData];
    }else{
        [menuNavController initStreams];
        [menuNavController reload];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    self.aggregationStep = AggregationStepDay;
    [self loadSettings];
    [self resetDateFormatters];
    
    //self.navigationController.navigationBar.layer.masksToBounds = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidReceiveAccessTokenNotification:)
                                                 name:kAppDidReceiveAccessTokenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogoutNotification:)
                                                 name:kUserDidLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidCloseNotification:)
                                                 name:kDrawerDidCloseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserShouldUpdateNotification:)
                                                 name:kBrowserShouldUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserShouldScrollToEvent:)
                                                 name:kBrowserShouldScrollToEvent
                                               object:nil];
    
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kPYAppSettingUIDisplayNonStandardEvents
                                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    self.pullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60 tableView:self.tableView withClient:self];
    
    [self setupLeftMenuButton];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.title = NSLocalizedString(@"BrowserViewController.Title", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsetFilter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSettings
{
    displayNonStandardEvents = [[NSUserDefaults standardUserDefaults] boolForKey:kPYAppSettingUIDisplayNonStandardEvents];
}

- (void)refreshFilter // called be loadData
{
    
    NSMutableArray* typeFilter = [NSMutableArray arrayWithObjects:@"note/txt", @"picture/attached", nil];
    [typeFilter addObjectsFromArray:[[PYEventTypes sharedInstance] classesFilterWithNumericalValues]];
    
    if (self.filter == nil) {
        [self clearCurrentData];
        
        [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:^{
        } withCompletionBlock:^(PYConnection *connection) {
            
            self.filter = [[PYEventFilter alloc] initWithConnection:connection
                                                           fromTime:[self fromTime]
                                                             toTime:[self toTime]
                                                              limit:kFilterInitialLimit
                                                     onlyStreamsIDs:[self listStreamFilter]
                                                               tags:nil
                                                              types:typeFilter
                           ];
            self.filter.state = PYEventFilter_kStateDefault;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterEventUpdate:)
                                                         name:kPYNotificationEvents object:self.filter];
            
            // get filter's data now ..
            [self.filter update];
            //[self.tableView reloadData];
        }];
        
    } else {
        
        self.filter.fromTime = [self fromTime];
        self.filter.toTime = [self toTime];
        self.filter.limit = 100;
        self.filter.onlyStreamsIDs = [self listStreamFilter];
        
        [self.filter update];
        
        [[NotesAppController sharedInstance].connection updateCache:nil];
    }
}

-(NSTimeInterval) fromTime
{
    return PYEventFilter_UNDEFINED_FROMTIME;
    /*MenuNavController* menuNavController = (MenuNavController*)[self.mm_drawerController leftDrawerViewController];
    return [[[menuNavController getDate] dateByAddingTimeInterval:-60*60*24*15] timeIntervalSince1970];*/
}

-(NSTimeInterval) toTime
{
    return PYEventFilter_UNDEFINED_TOTIME;
    MenuNavController* menuNavController = (MenuNavController*)[self.mm_drawerController leftDrawerViewController];
    return [[menuNavController getDate] timeIntervalSince1970];
}

-(NSArray*) listStreamFilter
{
    MenuNavController* menuNavController = (MenuNavController*)[self.mm_drawerController leftDrawerViewController];
    NSArray* streams = [menuNavController getMenuStreams];
    return streams;
    //return nil;
}

- (void)unsetFilter // called by clearData
{
    if (self.filter != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kPYNotificationEvents object:self.filter];
        self.filter = nil;
    }
}

#pragma mark - data

- (void)loadData
{
    NSLog(@"*261");
    static BOOL isLoading;
    if(!isLoading)
    {
        isLoading = YES;        
        [self.pullToRefreshManager tableViewReloadFinishedAnimated:YES];
    }
    isLoading = NO;
    
    
    // refresh stream.. can be done asynchronously
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:^{
        
    } withCompletionBlock:^(PYConnection *connection) {
        [connection streamsOnlineWithFilterParams:nil successHandler:nil errorHandler:nil];
    }];
    [self refreshFilter];
    
}


#pragma mark - Sections manipulations

- (void)resetDateFormatters {
    if (self.sectionsKeyFormatter == nil) {
        self.sectionsKeyFormatter = [[NSDateFormatter alloc] init]; }
    if (self.sectionsTitleFormatter == nil) { self.sectionsTitleFormatter = [[NSDateFormatter alloc] init];}
    if (self.cellDateFormatter == nil) { self.cellDateFormatter = [[NSDateFormatter alloc] init];}
    
    [self.cellDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.cellDateFormatter setDoesRelativeDateFormatting:YES];

    [self.sectionsTitleFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[self.sectionsTitleFormatter setDateFormat:@"dd.MM.yyyy"];
    [self.sectionsTitleFormatter setDoesRelativeDateFormatting:YES];
    
    switch (self.aggregationStep) {
        case AggregationStepMonth:
            [self.sectionsKeyFormatter setDateFormat:@"yyyy-MM"];
            break;
        case AggregationStepYear:
            [self.sectionsKeyFormatter setDateFormat:@"yyyy"];
            break;
        default:
            [self.sectionsKeyFormatter setDateFormat:@"yyyy-MM-dd"];
            [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
            break;
    }
}

- (void)rebuildSectionMap {
    
    NSArray* events = nil;
    if (self.filter != nil) {
        if (self.sectionsMap == nil) {
            self.sectionsMap = [[NSMutableDictionary alloc] init];
            self.sectionsMapTitles = [[NSMutableOrderedSet alloc] init];
        } else {
            [self.sectionsMap removeAllObjects];
            [self.sectionsMapTitles removeAllObjects];
        }
        events = [self.filter currentEventsSet];
    }
    
    
    if (events == nil) return;
    
    // go thru all events and set one section per date
    for (PYEvent* event in events) {
        if ([self clientFilterMatchEvent:event]) {
            [self addToSectionMapEvent:event];
        }
    }
}

- (void)addToSectionMapEvent:(PYEvent*)event {

    NSString* sectionKey = [self.sectionsKeyFormatter stringFromDate:event.eventDate];
    
    NSMutableOrderedSet* eventList = [self.sectionsMap objectForKey:sectionKey];
    if (eventList == nil) {
        eventList = [[NSMutableOrderedSet alloc] init];
        [self.sectionsMap setValue:eventList forKey:sectionKey];
        MySection* mySection = [[MySection alloc] init];
        mySection.time = [event.eventDate timeIntervalSince1970];
        mySection.key = sectionKey;
        mySection.title = [self.sectionsTitleFormatter stringFromDate:event.eventDate];
        
        
        // find the right place for this section
        MySection* kSection = nil;
        BOOL found = false;
        if (self.sectionsMapTitles.count > 0) {
            for (int k = 0; k < self.sectionsMapTitles.count; k++) {
                kSection = [self.sectionsMapTitles objectAtIndex:k];
                if ([kSection time] < [mySection time]) {
                    [self.sectionsMapTitles insertObject:mySection atIndex:k];
                    found = true;
                    break;
                }
            }
        }
        if (! found) {
            [self.sectionsMapTitles addObject:mySection];
        }
    }
    
    PYEvent* kEvent = nil;
    if (eventList.count > 0) {
        for (int k = 0; k < eventList.count; k++) {
            kEvent = [eventList objectAtIndex:k];
            if ([kEvent getEventServerTime] < [event getEventServerTime]) {
                [eventList insertObject:event atIndex:k];
                return;
            }
        }
    }
    [eventList addObject:event];
}

- (NSMutableOrderedSet*) sectionDataAtIndex:(NSInteger)index {
    
    if (! self.sectionsMapTitles) {
        NSLog(@"<WARNING> BrowseEventsViewController.sectionDataAtIndex empty sectionsMapTitles");
        return nil;
    }
    if (index >= self.sectionsMapTitles.count) {
        NSLog(@"<WARNING> BrowseEventsViewController.sectionDataAtIndex index not reachable: %ld",(long)index);
        return nil;
    }
    NSString* sectionKey = [[self.sectionsMapTitles objectAtIndex:index] key];
    return [self.sectionsMap objectForKey:sectionKey];
}

- (PYEvent*) eventAtIndexPath:(NSIndexPath *)indexPath {
    return [[self sectionDataAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}


#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (! self.sectionsMap) {
        [self rebuildSectionMap];
    }
    NSInteger count = [self.sectionsMapTitles count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:kSectionCell];
    UILabel *targetedLabel = (UILabel *)[headerCell viewWithTag:kSectionLabel];
    
    [headerCell.contentView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:0.8]];
    
    if (section >= self.sectionsMapTitles.count) {
        NSLog(@"<WARNING> BrowseEventsViewController.tableView  index not reachable: %ld",(long)index);
        [targetedLabel setText:@"..."];
    } else [targetedLabel setText:[[self.sectionsMapTitles objectAtIndex:section] title]];
    
    return headerCell.contentView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self sectionDataAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCell:indexPath];
}

-(CGFloat) heightForCell:(NSIndexPath *)indexPath
{
    CGFloat result = 100.0;
    PYEvent *event = [self eventAtIndexPath:indexPath];
    CellStyleType cellStyleType = [event cellStyle];
    if (cellStyleType == CellStyleTypePhoto)
        result = 160.0;
    else if (cellStyleType == CellStyleTypeText)
        result = 90.0;
    else if (cellStyleType == CellStyleTypeMeasure)
        result = 65.0;
    else if (cellStyleType == CellStyleTypeMoney)
        result = 65.0;
    else
        NSLog(@"Warnign : type cell is not photo, text or measure.");
    return result;
}

- (void)loadMoreDataForIndexPath:(NSIndexPath*)indexPath
{
    if(self.lastIndexPath.row == indexPath.row)
    {
        return;
    }
    self.lastIndexPath = indexPath;
    self.filter.limit+=kFilterIncrement;
    [self loadData];
}

- (BrowseCell *)cellInTableView:(UITableView *)tableView forCellStyleType:(CellStyleType)cellStyleType
{
    BrowseCell *cell;
    if(cellStyleType == CellStyleTypePhoto)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PictureCell_ID"];
    }
    else if(cellStyleType == CellStyleTypeText)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell_ID"];
    }
    else if (cellStyleType == CellStyleTypeMeasure || cellStyleType == CellStyleTypeMoney)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ValueCell_ID"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UnkownCell_ID"];
    }
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PYEvent *event = [self eventAtIndexPath:indexPath];
    CellStyleType cellStyleType = [event cellStyle];
    BrowseCell *cell = [self cellInTableView:tableView forCellStyleType:cellStyleType];
    [cell setDateFormatter:self.cellDateFormatter];
    [cell updateWithEvent:event];
    return cell;
}

#pragma mark - Event List manipulations

- (BOOL)clientFilterMatchEvent:(PYEvent*)event
{
    if (event.trashed) return NO;
    return displayNonStandardEvents || ! ([event cellStyle] == CellStyleTypeUnkown );
}

- (void)clearCurrentData
{
    [self rebuildSectionMap];
    [self unsetFilter];
    [self.tableView reloadData];
}


#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (keyPath == kPYAppSettingUIDisplayNonStandardEvents) {
        [self loadSettings];
        [self clearCurrentData];
        [self refreshFilter];
    }
}


#pragma mark - IBAction, segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PYEvent*)sender
{
    if ([[segue identifier] isEqualToString:kValueToDetailSegue_ID]
        || [[segue identifier] isEqualToString:kPictureToDetailSegue_ID]
        || [[segue identifier] isEqualToString:kNoteToDetailSegue_ID]) {
        
        EventDetailsViewController *detail = [segue destinationViewController];
        BrowseCell *cell = (BrowseCell*)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        [detail setEvent:cell.event];
    }
}

#pragma mark - Notifications

-(void)browserShouldUpdateNotification:(NSNotification *)notification
{
    PYEvent *event = (PYEvent*)[notification object];
    [self refreshFilter];
    [self.tableView reloadData];
    [self scrollToEvent:event];
}

-(void)browserShouldScrollToEvent:(NSNotification*)notification
{
    PYEvent *event = (PYEvent*)[notification object];
    [self scrollToEvent:event];
}

- (void)drawerDidCloseNotification:(NSNotification *)notification
{
    [self loadData];
}


- (void)userDidReceiveAccessTokenNotification:(NSNotification *)notification
{
    [self.pullToRefreshManager setPullToRefreshViewVisible:YES];
    [self clearCurrentData];
    [self refreshFilter];
    [self loadData];
}

- (void)userDidLogoutNotification:(NSNotification *)notification
{
    [self clearCurrentData];

    //[self.pullToRefreshManager setPullToRefreshViewVisible:NO];
}

- (void)filterEventUpdate:(NSNotification *)notification
{
    
    NSDictionary *message = (NSDictionary*) notification.userInfo;
    
    
    
    NSArray* toAdd = [message objectForKey:kPYNotificationKeyAdd];
    NSArray* toRemove = [message objectForKey:kPYNotificationKeyDelete];
    NSArray* modify = [message objectForKey:kPYNotificationKeyModify];
    
    // [_tableView beginUpdates];
    // ref : http://www.nsprogrammer.com/2013/07/updating-uitableview-with-dynamic-data.html
    // ref2 : http://stackoverflow.com/questions/4777683/how-do-i-efficiently-update-a-uitableview-with-animation
    
  
    
    // events are sent ordered by time
    if (toRemove) {
        NSLog(@"*262 REMOVE %lu", (unsigned long)toRemove.count);
        
    }
    
    if (modify) {
        NSLog(@"*262 MODIFY %d", modify.count);

    }
    
    // events are sent ordered by time
    if (toAdd && toAdd.count > 0) {
        
        NSLog(@"*262 ADD %d", toAdd.count);
        
        
    }
    
    
    if ((toAdd.count + modify.count + toRemove.count) == 0) {
        return;
    }
    
    
    [self rebuildSectionMap];
    
    
    // [_tableView endUpdates];
    NSLog(@"*262 END");
    [self.tableView reloadData]; // until update is implmeneted
    //[self hideLoadingOverlay];
    
}

#pragma mark - Utils

-(void) scrollToEvent:(PYEvent*)event
{
    
    [_tableView scrollToRowAtIndexPath:[self getIndexPathForEvent:event] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#warning Revoir la structure de données pour les sections, les méthodes et les algo.

-(NSIndexPath*)getIndexPathForEvent:(PYEvent*)event
{
    NSString *sectionKey = [self.sectionsKeyFormatter stringFromDate:event.eventDate];
    if (!sectionKey) return [NSIndexPath indexPathForRow:0 inSection:0];
    
    NSMutableOrderedSet* eventList = [self.sectionsMap objectForKey:sectionKey];
    if (!eventList)
        return [NSIndexPath indexPathForRow:0 inSection:[self closeSectionIndex:[event.eventDate timeIntervalSince1970]]];
    
    if (eventList.count > 0) {
        for (int k = 0; k < eventList.count; k++) {
            if ([[eventList objectAtIndex:k] getEventServerTime] == [event getEventServerTime])
                return [NSIndexPath indexPathForRow:k inSection:[self sectionIndex:sectionKey]];
            
            if ([[eventList objectAtIndex:k] getEventServerTime] < [event getEventServerTime])
                return [NSIndexPath indexPathForRow:k inSection:[self sectionIndex:sectionKey]];
        }
    }

    return [NSIndexPath indexPathForRow:0 inSection:[_sectionsMapTitles count]-1];
    
}

-(NSInteger) sectionIndex:(NSString*)sectionKey
{
    for (int i=0; i<[_sectionsMapTitles count]; i++) {
        if ([[(MySection*)[_sectionsMapTitles objectAtIndex:i] key] isEqualToString:sectionKey])
            return i;
        
    }
    return 0;
}

-(NSInteger) closeSectionIndex:(NSTimeInterval)time
{
    for (int i=0; i<[_sectionsMapTitles count]; i++) {
        if ([(MySection*)[_sectionsMapTitles objectAtIndex:i] time] < time)
            return i;
        
    }
    return [_sectionsMapTitles count]-1;
}


#pragma mark - MNMPullToRefreshManagerClient methods

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self loadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullToRefreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullToRefreshManager tableViewReleased];
}

- (NSDate*)lastUpdateDateForManager:(MNMPullToRefreshManager *)manager
{
    return [NSDate dateWithTimeIntervalSince1970:self.filter.modifiedSince];
}


@end



