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
#import "TextEditorViewController.h"
#import <PryvApiKit/PYConstants.h>
#import "MCSwipeTableViewCell.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuNavController.h"


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
#define kFilterIncrement 50

typedef enum {
    AggregationStepDay = 1,
    AggregationStepMonth,
    AggregationStepYear
} AggregationStep;


static NSString *browseCellIdentifier = @"BrowseEventsCell_ID";

@interface BrowseEventsViewController () <UIActionSheetDelegate,MNMPullToRefreshManagerClient,MCSwipeTableViewCellDelegate>


@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableDictionary *sectionsMap;
@property (nonatomic, strong) NSMutableOrderedSet *sectionsMapTitles;

@property (nonatomic, strong) NSArray *shortcuts;
@property (nonatomic, strong) MNMPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, strong) PYEvent *eventToShowOnAppear;
@property (nonatomic, strong) UIWebView *welcomeWebView;

@property (nonatomic, strong) PYEventFilter *filter;
@property (nonatomic, strong) NSNumber *isSourceTypePicked;
@property (nonatomic, strong) UserHistoryEntry *tempEntry;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@property (nonatomic) AggregationStep aggregationStep;

- (void)loadData;
- (void)didReceiveEventAddedNotification:(NSNotification*)notification;
- (void)userDidReceiveAccessTokenNotification:(NSNotification*)notification;
- (void)filterEventUpdate:(NSNotification*)notification;
- (int)addEventToList:(PYEvent*)eventToAdd;

- (void)refreshFilter;
- (void)unsetFilter;
- (MMDrawerController*)mm_drawerController;
- (void)showWelcomeWebView:(BOOL)visible;

@end

@implementation BrowseEventsViewController

BOOL displayNonStandardEvents;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.aggregationStep = AggregationStepDay;
    }
    return self;
}

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
    if ([self.mm_drawerController openSide]==MMDrawerSideLeft) {
        MenuNavController* menuNavController = (MenuNavController*)[self.mm_drawerController leftDrawerViewController];
        [menuNavController resetMenu];

        [self unsetFilter];
        [self loadData];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadSettings];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BrowseEventCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:browseCellIdentifier];
    
    self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    //self.navigationItem.title = @"Pryv";
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_pryv"] target:self action:@selector(settingButtonTouched:)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveEventAddedNotification:)
                                                 name:kEventAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidReceiveAccessTokenNotification:)
                                                 name:kAppDidReceiveAccessTokenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogoutNotification:)
                                                 name:kUserDidLogoutNotification
                                               object:nil];
    // Monitor changes of option "show non standard events"
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kPYAppSettingUIDisplayNonStandardEvents
                                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    self.pullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60 tableView:self.tableView withClient:self];
    
    
    self.events = [[NSMutableArray alloc] init];
    
    
    
    self.tableView.alpha = 0.0f;
    [self setupLeftMenuButton];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Pryv";
    [self loadShortcuts];
}

- (void)loadShortcuts
{
    __block BrowseEventsViewController *weakSelf = self;
    [[LRUManager sharedInstance] fetchLRUEntriesWithCompletionBlock:^{
        weakSelf.shortcuts = [[LRUManager sharedInstance] lruEntries];
        if(IS_LRU_SECTION)
        {
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.eventToShowOnAppear)
    {
        PYEvent *event = self.eventToShowOnAppear;
        self.eventToShowOnAppear = nil;
        [self showEventDetailsForEvent:event andUserHistoryEntry:nil];
        self.pickedImage = nil;
        self.pickedImageTimestamp = nil;
    }
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

#pragma mark - setup

- (void)showWelcomeWebView:(BOOL)visible {
    if (visible) {
        if (_welcomeWebView) return;
        
        [self.welcomeWebView removeFromSuperview];
        [self.view addSubview:self.welcomeWebView];
    } else {
        if (_welcomeWebView == nil) return;
        [self.welcomeWebView removeFromSuperview];
        self.welcomeWebView = nil;
    }
}

- (void)refreshFilter // called be loadData
{
    if (self.filter == nil) {
        [self clearCurrentData];
        
        [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:^{
            [self showWelcomeWebView:YES];
        } withCompletionBlock:^(PYConnection *connection) {
            
            self.filter = [[PYEventFilter alloc] initWithConnection:connection
                                                           fromTime:[self fromTime]
                                                             toTime:[self toTime]
                                                              limit:kFilterInitialLimit
                                                     onlyStreamsIDs:[self listStreamFilter]
                                                               tags:nil
                                                              types:nil
                           ];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterEventUpdate:)
                                                         name:kPYNotificationEvents object:self.filter];
            [self.filter update];
            
        }];
        
    } else {
        [self.filter update];
    }
}

-(NSTimeInterval) fromTime
{
    return PYEventFilter_UNDEFINED_FROMTIME;
    MenuNavController* menuNavController = (MenuNavController*)[self.mm_drawerController leftDrawerViewController];
    return [[[menuNavController getDate] dateByAddingTimeInterval:-60*60*24*15] timeIntervalSince1970];
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
    if ([streams count]==0)
        return nil;
    return streams;
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
        [self showLoadingOverlay];
        
        [self.tableView reloadData];
        if(self.lastIndexPath)
        {
            if (self.lastIndexPath.row <0) {
                self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.lastIndexPath.section];
            }
            NSInteger numRows = [self tableView:self.tableView numberOfRowsInSection:self.lastIndexPath.section];
            if (self.lastIndexPath.row >= numRows) {
                self.lastIndexPath = [NSIndexPath indexPathForRow:numRows - 1  inSection:0];
            }
            
            [self.tableView scrollToRowAtIndexPath:self.lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.alpha = 1.0f;
        }];
        [self hideLoadingOverlay];
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


- (void)rebuildSectionMap {
    if (self.sectionsMap == nil) {
        self.sectionsMap = [[NSMutableDictionary alloc] init];
        self.sectionsMapTitles = [[NSMutableOrderedSet alloc] init];
    } else {
        [self.sectionsMap removeAllObjects];
        [self.sectionsMapTitles removeAllObjects];
    }
    
    // go thru all events and set one section per date
    for (PYEvent* event in self.events) {
        [self addToSectionMapEvent:event];
    }
}

- (void)addToSectionMapEvent:(PYEvent*)event {
    NSDateFormatter *sectionKeyFormatter = [[NSDateFormatter alloc] init];
    
    
    NSDateFormatter *sectionTitleFormatter = [[NSDateFormatter alloc] init];
    //[sectionTitleFormatter setDateStyle:NSDateFormatterShortStyle];
    [sectionTitleFormatter setDateStyle:NSDateFormatterLongStyle];
    [sectionTitleFormatter setDoesRelativeDateFormatting:YES];
    
    switch (self.aggregationStep) {
        case AggregationStepMonth:
            [sectionKeyFormatter setDateFormat:@"yyyy-MM"];
            break;
        case AggregationStepYear:
            [sectionKeyFormatter setDateFormat:@"yyyy"];
            break;
        default:
            [sectionKeyFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
    }
    
    
    
    
    NSString* sectionKey = [sectionKeyFormatter stringFromDate:event.eventDate];
    
    NSMutableOrderedSet* eventList = [self.sectionsMap objectForKey:sectionKey];
    if (eventList == nil) {
        eventList = [[NSMutableOrderedSet alloc] init];
        [self.sectionsMap setValue:eventList forKey:sectionKey];
        MySection* mySection = [[MySection alloc] init];
        mySection.time = [event.eventDate timeIntervalSince1970];
        mySection.key = sectionKey;
        mySection.title = [sectionTitleFormatter stringFromDate:event.eventDate];
        
        
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
            kEvent = [self.events objectAtIndex:k];
            if ([kEvent getEventServerTime] < [event getEventServerTime]) {
                [eventList insertObject:event atIndex:k];
                return;
            }
        }
    }
    [eventList addObject:event];
}

- (NSMutableOrderedSet*) sectionDataAtIndex:(NSInteger)index {
    NSString* sectionKey = [[self.sectionsMapTitles objectAtIndex:index] key];
    return [self.sectionsMap objectForKey:sectionKey];
}

- (PYEvent*) eventAtIndexPath:(NSIndexPath *)indexPath {
    return [[self sectionDataAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}


#pragma mark - UITableViewDelegate and UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(IS_LRU_SECTION || [tableView isEqual:self.menuTableView])
    {
        return 1;
    }
    if (! self.sectionsMap) {
        [self rebuildSectionMap];
    }
    NSInteger count = [self.sectionsMapTitles count];
    [self showWelcomeWebView:(count == 0)];
    return count;
    
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(IS_LRU_SECTION || [tableView isEqual:self.menuTableView])
    {
        return nil;
    }
    return [[self.sectionsMapTitles objectAtIndex:section] title];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    if(IS_BROWSE_SECTION)
    {
        
        return [[self sectionDataAtIndex:section] count];
    }
    if(IS_LRU_SECTION)
    {
        [self showWelcomeWebView:NO];
        return [self.shortcuts count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    if(IS_BROWSE_SECTION)
    {
        return 160;
    }
    if(IS_LRU_SECTION)
    {
        return 70;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [self.events count] - 1)
    {
        [self loadMoreDataForIndexPath:indexPath];
    }
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
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    
    if(IS_BROWSE_SECTION)
    {
        PYEvent *event = [self eventAtIndexPath:indexPath];
        CellStyleType cellStyleType = [event cellStyle];
        BrowseCell *cell = [self cellInTableView:tableView forCellStyleType:cellStyleType];
        [cell updateWithEvent:event];
        [cell prepareForReuse];
        return cell;
    }
    NSInteger row = indexPath.row;
    BrowseEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:browseCellIdentifier];
    UserHistoryEntry *entry = [_shortcuts objectAtIndex:row];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [cell setupWithUserHistroyEntry:entry];
    return cell;
    
}

- (void)configureCell:(MCSwipeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    [cell setDefaultColor:[UIColor lightGrayColor]];
    [cell setDelegate:self];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSIndexPath *indexPathToDelete = [self.tableView indexPathForCell:cell];
        [[LRUManager sharedInstance] removeObjectFromLruEntriesAtIndex:indexPathToDelete.row];
        self.shortcuts = [LRUManager sharedInstance].lruEntries;
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    if(IS_LRU_SECTION)
    {
        UserHistoryEntry *entry = [_shortcuts objectAtIndex:indexPath.row];
        [self showEventDetailsWithUserHistoryEntry:entry];
    }
    else
    {
        self.lastIndexPath = indexPath;
        PYEvent *event = [self eventAtIndexPath:indexPath];
        [self showEventDetailsForEvent:event andUserHistoryEntry:nil];
    }
}

- (void)topMenuDidSelectOptionAtIndex:(NSInteger)index
{
    __block BrowseEventsViewController *weakSelf = self;
    [self setMenuVisible:NO animated:YES withCompletionBlock:^{
        switch (index) {
            case 0:
            {
                PYEvent *event = [[PYEvent alloc] init];
                event.type = @"note/txt";
                [weakSelf showEventDetailsForEvent:event andUserHistoryEntry:nil];
            }
                break;
            case 1:
            {
                PYEvent *event = [[PYEvent alloc] init];
                [weakSelf showEventDetailsForEvent:event andUserHistoryEntry:nil];
            }
                break;
            case 2:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Alert.Message.PhotoSource", nil) delegate:weakSelf cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil),NSLocalizedString(@"Library", nil), nil];
                [actionSheet showInView:weakSelf.view];
            }
                break;
            default:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This option is not yet implemented" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
                break;
        }
    }];
}

#pragma mark - Show details


- (void)showEventDetailsWithUserHistoryEntry:(UserHistoryEntry*)entry
{
    self.tempEntry = entry;
    __weak typeof(self) weakSelf = self;
    [self setMenuVisible:NO animated:YES withCompletionBlock:^{
        PYEvent *event = [entry reconstructEvent];
        [weakSelf showEventDetailsForEvent:event andUserHistoryEntry:entry];
    }];
    
}

- (void)showEventDetailsForEvent:(PYEvent*)event andUserHistoryEntry:(UserHistoryEntry*)entry
{
    if (event == nil) {
        [NSException raise:@"Event is nil" format:nil];
    }
    
    EventDetailsViewController *eventDetailVC = (EventDetailsViewController*)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController_ID"];
    eventDetailVC.event = event;
    
    self.title = NSLocalizedString(@"Back", nil);
    EventDataType eventType = [eventDetailVC.event eventDataType];
    
    /**
     TextEditorViewController *textVC = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"TextEditorViewController_ID"];
     
     [eventDetailVC setupDescriptionEditorViewController:textVC];
     **/
    
    if(eventType == EventDataTypeImage)
    {
        eventDetailVC.imagePickerType = self.imagePickerType;
    }
    
    if(event.isDraft)
    {
        [eventDetailVC view];
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [viewControllers addObject:eventDetailVC];
        if(eventType == EventDataTypeNote && eventDetailVC.event.type != nil)
        {
            TextEditorViewController *textVC = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"TextEditorViewController_ID"];
            
            [eventDetailVC setupNoteContentEditorViewController:textVC];
            [textVC setupCustomCancelButton];
            [viewControllers addObject:textVC];
        }
        else if(eventType == EventDataTypeValueMeasure || eventDetailVC.event.type == nil)
        {
            AddNumericalValueViewController *addVC = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"AddNumericalValueViewController_ID"];
            [eventDetailVC setupAddNumericalValueViewController:addVC];
            [addVC setupCustomCancelButton];
            [viewControllers addObject:addVC];
        }
        else if(!self.pickedImage)
        {
            if(!self.isSourceTypePicked)
            {
                [self topMenuDidSelectOptionAtIndex:2];
                return;
            }
            
            PhotoNoteViewController *photoVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"PhotoNoteViewController_ID"];
            photoVC.sourceType = [self.isSourceTypePicked integerValue];
            self.isSourceTypePicked = nil;
            photoVC.browseVC = self;
            photoVC.entry = entry;
            [photoVC setImagePickedBlock:^(UIImage *image, NSDate *date, UIImagePickerControllerSourceType source) {
                [eventDetailVC.event setEventDate:date];
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                if(imageData)
                {
                    NSString *imgName = [NSString randomStringWithLength:10];
                    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:imgName fileName:[NSString stringWithFormat:@"%@.jpeg",imgName]];
                    [eventDetailVC.event addAttachment:att];
                }
                self.pickedImage = nil;
                self.pickedImageTimestamp = nil;
                self.eventToShowOnAppear = nil;
                [eventDetailVC updateUIForCurrentEvent];
            }];
            [viewControllers addObject:photoVC];
        }
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:eventDetailVC animated:YES];
    }
    
}

#pragma mark - Top menu visibility changed

- (void)topMenuVisibilityWillChange
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)topMenuVisibilityDidChange
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Actions

/*- (void)settingButtonTouched:(id)sender
{
    SettingsViewController *settingsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController_ID"];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    navVC.navigationBar.translucent = NO;
    [self presentViewController:navVC animated:YES completion:nil];
}*/


#pragma mark - Event List manipulations


- (BOOL)clientFilterMatchEvent:(PYEvent*)event
{
    if (event.trashed) return NO;
    return displayNonStandardEvents || ! ([event cellStyle] == CellStyleTypeUnkown );
}

/**
 * add an event to the list, will match it against current client filter
 * return index of event Added, -1 if not added
 */
- (int)addEventToList:(PYEvent*) eventToAdd {
    if (! [self clientFilterMatchEvent:eventToAdd]) {
        return -1;
    }
    PYEvent* kEvent = nil;
    if (self.events.count > 0) {
        for (int k = 0; k < self.events.count; k++) {
            kEvent = [self.events objectAtIndex:k];
            if ([kEvent getEventServerTime] < [eventToAdd getEventServerTime]) {
                [self.events insertObject:eventToAdd atIndex:k];
                return k;
            }
        }
    }
    [self.events addObject:eventToAdd];
    return self.events.count;
}


- (void)clearCurrentData
{
    [self.events removeAllObjects];
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

#pragma mark - Notifications

- (void)didReceiveEventAddedNotification:(NSNotification*)notification
{
    [self.navigationController popToViewController:self animated:YES];
    [self loadData];
}

- (void)userDidReceiveAccessTokenNotification:(NSNotification *)notification
{
    [self.pullToRefreshManager setPullToRefreshViewVisible:YES];
    [self loadData];
}

- (void)userDidLogoutNotification:(NSNotification *)notification
{
    [self.pullToRefreshManager setPullToRefreshViewVisible:NO];
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
    
    
    // firstOfAll check event order and add them to toAdd array fo rearranging
    [PYEventFilter sortNSMutableArrayOfPYEvents:self.events sortAscending:NO];
    
    
    
    
    // events are sent ordered by time
    if (toRemove) {
        NSLog(@"*262 REMOVE %i", toRemove.count);
        
        PYEvent* kEvent = nil;
        PYEvent* eventToRemove = nil;
        for (int i = toRemove.count -1 ; i >= 0; i--) {
            eventToRemove = [toRemove objectAtIndex:i];
            for (int k =  (self.events.count - 1) ; k >= 0 ; k--) {
                kEvent = [self.events objectAtIndex:k];
                if ([eventToRemove.eventId isEqualToString:kEvent.eventId]) {
                    [self.events removeObjectAtIndex:k];
                    break; // assuming an event is only represented once in the list
                }
            }
        }
        
    }
    
    if (modify) {
        NSLog(@"*262 MODIFY %i", modify.count);
        // remove events marked as trashed
        PYEvent* kEvent = nil;
        PYEvent* eventToCheck = nil;
        for (int i = modify.count -1 ; i >= 0; i--) {
            eventToCheck = [modify objectAtIndex:i];
            if (eventToCheck.trashed) {
                for (int k =  (self.events.count - 1) ; k >= 0 ; k--) {
                    kEvent = [self.events objectAtIndex:k];
                    if ([eventToCheck.eventId isEqualToString:kEvent.eventId]) {
                        [self.events removeObjectAtIndex:k];
                        break; // assuming an event is only represented once in the list
                    }
                }
            }
        }
    }
    
    // events are sent ordered by time
    if (toAdd && toAdd.count > 0) {
        
        NSLog(@"*262 ADD %i", toAdd.count);
        
        for (int i = toAdd.count - 1 ; i >= 0; i--) {
            [self addEventToList:[toAdd objectAtIndex:i]];
        }
        
    }
    
    
    [self rebuildSectionMap];
    
    
    // [_tableView endUpdates];
    NSLog(@"*262 END");
    [self.tableView reloadData]; // until update is implmeneted
    [self hideLoadingOverlay];
    
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex)
    {
        self.tempEntry = nil;
        self.isSourceTypePicked = nil;
        return;
    }
    UIImagePickerControllerSourceType sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    if(self.tempEntry)
    {
        UserHistoryEntry *entry = self.tempEntry;
        self.isSourceTypePicked = @(sourceType);
        [self showEventDetailsWithUserHistoryEntry:entry];
        self.tempEntry = nil;
        return;
    }
    PhotoNoteViewController *photoVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"PhotoNoteViewController_ID"];
    photoVC.sourceType = sourceType;
    photoVC.browseVC = self;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (void)setPickedImage:(UIImage *)pickedImage
{
    if(_pickedImage != pickedImage)
    {
        _pickedImage = pickedImage;
        [self showImageDetails];
    }
}

- (void)showImageDetails
{
    PYEvent *event = [[PYEvent alloc] init];
    event.type = @"picture/attached";
    if(self.pickedImageTimestamp)
    {
        [event setEventDate:self.pickedImageTimestamp];
    }
    NSData *imageData = UIImageJPEGRepresentation(self.pickedImage, 0.5);
    if(imageData)
    {
        NSString *imgName = [NSString randomStringWithLength:10];
        PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:imgName fileName:[NSString stringWithFormat:@"%@.jpeg",imgName]];
        [event addAttachment:att];
        self.eventToShowOnAppear = event;
    }
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (UIWebView*)welcomeWebView
{
    if(!_welcomeWebView)
    {
        _welcomeWebView = [[UIWebView alloc] initWithFrame:self.tableView.frame];
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        [_welcomeWebView loadHTMLString:htmlString baseURL:nil];
    }
    return _welcomeWebView;
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



