//
//  DetailViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 03.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DetailViewController.h"
#import "NoteDetailCell.h"
#import "NumericDetailCell.h"
#import "PhotoDetailCell.h"
#import "StreamDetailCell.h"
#import "DatePickerDetailCell.h"
#import "DateDetailCell.h"
#import "EndDateDetailCell.h"
#import "TagsDetailCell.h"
#import "DescriptionDetailCell.h"
#import "DeleteDetailCell.h"
#import "EventDetailCell.h"
#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"
#import "PYStream+Utils.h"
#import "UIAlertView+PrYv.h"
#import "DataService.h"
#import "StreamPickerViewController.h"
#import "UserHistoryEntry.h"

typedef enum
{
    DetailCellTypeEvent,
    DetailCellTypeStreams,
    DetailCellTypeTime,
    DetailCellTypeTimePicker,
    DetailCellTypeTimeEnd,
    DetailCellTypeTimeEndPicker,
    DetailCellTypeTags,
    DetailCellTypeDescription,
    DetailCellTypeDelete
    
} DetailCellType;

@interface DetailViewController () <StreamsPickerDelegate, DetailCellDelegate>

@property (nonatomic) BOOL isEdit;
@property (nonatomic) BOOL shouldUpdateEvent;
@property (nonatomic, strong) NSDictionary *initialEventValue;
@property (nonatomic, strong) UIBarButtonItem *btBrowse, *btCancel;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, weak) IBOutlet EventDetailCell *eventDetailCell;
@property (nonatomic, weak) IBOutlet StreamDetailCell *streamDetailCell;
@property (nonatomic, weak) IBOutlet DateDetailCell *dateDetailCell;
@property (nonatomic, weak) IBOutlet DatePickerDetailCell *datePickerDetailCell;
@property (nonatomic, weak) IBOutlet EndDateDetailCell *endDateDetailCell;
@property (nonatomic, weak) IBOutlet DatePickerDetailCell *endDatePickerDetailCell;
@property (nonatomic, weak) IBOutlet TagsDetailCell *tagsDetailCell;
@property (nonatomic, weak) IBOutlet DescriptionDetailCell *descriptionDetailCell;
@property (nonatomic, weak) IBOutlet DeleteDetailCell *deleteDetailCell;

@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isEdit = self.event.isDraft;
    self.initialEventValue = [self.event cachingDictionary];

    self.btBrowse= [[UIBarButtonItem alloc]
                    initWithTitle: NSLocalizedString(@"Browser", nil)
                    style:UIBarButtonItemStylePlain
                    target:self
                    action:@selector(btBrowsePressed:)];
    self.btCancel= [[UIBarButtonItem alloc]
                    initWithTitle: NSLocalizedString(@"Cancel", nil)
                    style:UIBarButtonItemStylePlain
                    target:self
                    action:@selector(cancelButtonTouched:)];
    
    self.dateDetailCell.isDatePicker = false;
    self.endDateDetailCell.isEndDatePicker = false;
    
    [self updateEvent];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) updateEvent
{
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setDelegate:self];
        [cell updateWithEvent:self.event];
    }];
}

#pragma mark - IBAction

-(void) btBrowsePressed:(id)sender
{
    if (![[self.initialEventValue objectForKey:@"streamId"] isEqualToString:self.event.streamId]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidAddStreamNotification object:[self event]];
    }else if ([[NSDate dateWithTimeIntervalSince1970:[[self.initialEventValue  objectForKey:@"time"] doubleValue]] compare:self.event.eventDate] != NSOrderedSame)
        [[NSNotificationCenter defaultCenter] postNotificationName:kBrowserShouldScrollToEvent object:[self event]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editButtonTouched:(id)sender
{
    if (self.isEdit && (_event.stream == nil || _event.streamId == nil)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.DetailViewController.NoStream", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (self.event.eventDataType != EventDataTypeImage && (!self.event.eventContent || [self.event.eventContentAsString isEqualToString:@""])) {
        
        if (_event.eventDataType == EventDataTypeValueMeasure) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.DetailViewController.NoValue", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
        }
        
        if (_event.eventDataType == EventDataTypeNote) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.DetailViewController.NoNote", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
        }
        
        return;
    }
    
    [self updateUIEditMode:!self.isEdit];
}

- (IBAction)deleteButtonTouched:(id)sender {
    NSString* title = NSLocalizedString(@"Alert.Message.DeleteConfirmation", nil);
    if(self.event.isDraft)
    {
        title = NSLocalizedString(@"Alert.Message.CancelConfirmation", nil);
    }
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(alertView.cancelButtonIndex != buttonIndex)
            [self deleteEvent];

    }];
}

- (void)cancelButtonTouched:(id)sender
{
    if (self.event.isDraft) [self.navigationController popViewControllerAnimated:YES];
    else
    {
        if (self.initialEventValue) [self.event resetFromCachingDictionary:self.initialEventValue];
        [self updateEvent];
        self.shouldUpdateEvent = NO;
        [self updateUIEditMode:false];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    switch (indexPath.row) {
        case DetailCellTypeEvent:
            height = self.eventDetailCell.getHeight;
            break;
            
        case DetailCellTypeStreams:
            height = self.streamDetailCell.getHeight;
            break;
            
        case DetailCellTypeTime:
            height = self.dateDetailCell.getHeight;
            break;
        
        case DetailCellTypeTimePicker:
            if (self.dateDetailCell.isDatePicker) height = self.datePickerDetailCell.getHeight;
            break;
            
        case DetailCellTypeTimeEnd:
            height = self.endDateDetailCell.getHeight;
            break;
            
        case DetailCellTypeTimeEndPicker:
            if (self.endDateDetailCell.isEndDatePicker) height = self.endDatePickerDetailCell.getHeight;
            break;
            
        case DetailCellTypeTags:
            if (self.isEdit || self.event.tags.count > 0) height = self.tagsDetailCell.getHeight;
            break;
        
        case DetailCellTypeDescription:
            if (self.isEdit || [self.event.eventDescription length] > 0) height = self.descriptionDetailCell.getHeight;
            break;

        case DetailCellTypeDelete:
            if (self.isEdit) height = self.deleteDetailCell.getHeight;
            break;
            
        default:
            break;
    }
    
    return height;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailCellType cellType = indexPath.row;
    
    //if(!self.isEdit && cellType!=DetailCellTypeImage) return;
    
    
    //if (cellType != DetailCellTypeNote && cellType != DetailCellTypeDescription && cellType != DetailCellTypeTags && cellType != DetailCellTypeValue)
    [self.view endEditing:YES];
    
    
    if (cellType != DetailCellTypeTime && cellType != DetailCellTypeTimePicker && self.dateDetailCell.isDatePicker){
        self.dateDetailCell.isDatePicker = false;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
    if (cellType != DetailCellTypeTimeEnd && cellType != DetailCellTypeTimeEndPicker && self.endDateDetailCell.isEndDatePicker){
        self.endDateDetailCell.isEndDatePicker = false;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
    switch (cellType) {
        case DetailCellTypeEvent:
            [self.eventDetailCell didSelectCell:self];
            break;
            
        case DetailCellTypeTime:
        {
            if (self.isEdit) {
                self.dateDetailCell.isDatePicker = !self.dateDetailCell.isDatePicker;
                self.endDateDetailCell.isEndDatePicker = false;
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
                if (self.dateDetailCell.isDatePicker) {
                    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self.datePickerDetailCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                }
            }
        }
            break;
            
        case DetailCellTypeDescription:
            [self.descriptionDetailCell didSelectCell:self];
            break;
        case DetailCellTypeTags:
            [self.tagsDetailCell didSelectCell:self];
            break;
        
        case DetailCellTypeStreams:
        {
            if (self.isEdit) {
                StreamPickerViewController *streamPickerVC = [[UIStoryboard mainStoryBoard] instantiateViewControllerWithIdentifier:@"StreamPickerViewController_ID"];
                
                [self setupStreamPickerViewController:streamPickerVC];
            }
        }
            break;
            
        case DetailCellTypeTimeEnd:
        {
            
            if (self.endDateDetailCell.isEndDatePicker) {
                self.endDateDetailCell.isEndDatePicker = false;
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }else if (self.isEdit)
            {
                [self.endDateDetailCell didSelectCell:self];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - DetailCellDelegate

-(void) updateEndDateCell
{
    [self.endDateDetailCell updateLabels];
}

-(void) detailShouldUpdateEvent
{
    self.shouldUpdateEvent = true;
}

-(void) closePickers:(BOOL)forceUpdateUI
{
    if (self.dateDetailCell.isDatePicker || self.endDateDetailCell.isEndDatePicker) {
        self.dateDetailCell.isDatePicker = false;
        self.endDateDetailCell.isEndDatePicker = false;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }else if (forceUpdateUI)
    {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

#pragma mark - StreamPickerDelegate methods


- (void)closeStreamPicker:(PYStream*)stream
{
    if (stream) {
        self.event.streamId = stream.streamId;
        
        self.shouldUpdateEvent = YES;
    }
    [self.streamDetailCell update];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - utils

-(void) updateUIEditMode:(BOOL)edit
{
    [self.tableView beginUpdates];
    self.isEdit = edit;
    if (!edit) {
        self.dateDetailCell.isDatePicker = false;
        self.endDateDetailCell.isEndDatePicker = false;
        self.navigationItem.leftBarButtonItem = nil;
        [self.navigationItem setHidesBackButton:YES];
        self.navigationItem.leftBarButtonItem = self.btBrowse;
        [self.editButton setTitle:NSLocalizedString(@"Edit", nil)];
    }else{
        [self.editButton setTitle:NSLocalizedString(@"Done", nil)];
        [self.navigationItem setHidesBackButton:YES];
        
        self.navigationItem.leftBarButtonItem = self.btCancel;

    }
    if(self.event.isDraft && !edit)
        [self saveEvent];
    else if(self.shouldUpdateEvent && !edit)
        [self eventSaveModifications];
    
    //self.initialEventValue = [self.event cachingDictionary];
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:edit];
    }];
    [self.tableView endUpdates];
}

- (void)setupStreamPickerViewController:(StreamPickerViewController*)streamPickerVC
{
    streamPickerVC.delegate = self;
    [self.navigationController presentViewController:streamPickerVC animated:YES completion:nil];
}

- (void)saveEvent
{
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         
         [connection eventCreate:self.event andCacheFirst:YES
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event)
          {
              [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidCreateEventNotification object:[self event]];
              
              BOOL shouldTakePictureFlag = NO;
              [[DataService sharedInstance] saveEventAsShortcut:self.event andShouldTakePictureFlag:shouldTakePictureFlag];
              
          } errorHandler:^(NSError *error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
          }];
         
     }];
}

- (void)deleteEvent
{
    
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil withCompletionBlock:^(PYConnection *connection)
     {
         [connection eventTrashOrDelete:self.event successHandler:^{
             [self.navigationController popViewControllerAnimated:YES];
             [self hideLoadingOverlay];
         } errorHandler:^(NSError *error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
             [alert show];
             [self cancelButtonTouched:nil];
             //[self hideLoadingOverlay];
         }];
         
     }];
}

- (void)eventSaveModifications
{
    self.shouldUpdateEvent = false;
    [NotesAppController sharedConnectionWithID:nil
                   noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         [connection eventSaveModifications:self.event successHandler:^(NSString *stoppedId)
          {
          } errorHandler:^(NSError *error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
          }];
     }];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
