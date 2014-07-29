//
//  EventDetailsViewController.m
//  NotesApp
//
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "BaseDetailCell.h"
#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"
#import "PYStream+Utils.h"
#import "PYConnection.h"
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>
#import "StreamPickerViewController.h"
#import "DataService.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"
#import "UIAlertView+PrYv.h"
#import "ImageViewController.h"
#import "NotesAppController.h"
#import "MMDrawerController.h"
#import "MenuNavController.h"
#import "ZenKeyboard.h"
#import "DurationLabel.h"

#define kStreamCellHeight 54
#define kDeleteCellHeight 50
#define kDateCellHeight 66
#define kValueCellHeight 90
#define kImageCellHeight 320
#define kNoteTextViewWidth 297

#define kShowImagePreviewSegue @"ShowImagePreviewSegue_ID"
#define isiPhone5 ([UIScreen mainScreen].bounds.size.height == 568.0f)

typedef enum
{
    DetailCellTypeValue,
    DetailCellTypeImage,
    DetailCellTypeNote,
    DetailCellTypeStreams,
    DetailCellTypeTime,
    DetailCellTypeTimeExt,
    DetailCellTypeTimeEnd,
    DetailCellTypeTags,
    DetailCellTypeDescription,
    DetailCellTypeDelete
    
} DetailCellType;

@interface EventDetailsViewController () <StreamsPickerDelegate, JSTokenFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *previousStreamId;
@property (nonatomic, strong) NSDate *previousDate;
@property (nonatomic, strong) NSDictionary *initialEventValue;
@property (nonatomic) BOOL isDateExtHidden;
@property (nonatomic) BOOL isDateExtOwnedByStart;
@property (nonatomic) BOOL isInitialDraft;
@property (nonatomic) BOOL autoSetDiaryStream;
@property (nonatomic) BOOL isInEditMode;
@property (nonatomic) BOOL shouldUpdateEvent;
@property (nonatomic, strong) StreamPickerViewController *streamPickerVC;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;
@property (nonatomic, strong) IBOutlet UITableViewCell *noteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *dateExtCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *tagsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *descCell;

// -- specific properties

@property (nonatomic, weak) IBOutlet UIImageView *picture_ImageView;
@property (nonatomic, weak) IBOutlet UILabel *numericalValue_Label;
@property (nonatomic, weak) IBOutlet UILabel *numericalValue_TypeLabel;
@property (nonatomic, weak) IBOutlet UITextView *noteText;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionText;
@property (nonatomic, weak) IBOutlet UITextField *numericalValue;

// -- common properties

@property (nonatomic, weak) IBOutlet UIView *pastille;
@property (nonatomic, weak) IBOutlet JSTokenField *tokenField;
@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIDatePicker *timePicker;
@property (nonatomic, weak) IBOutlet UIView* addView;
@property (nonatomic, weak) IBOutlet UIView* setRunningView;
@property (nonatomic, weak) IBOutlet DurationLabel* lbDuration;
@property (nonatomic, weak) IBOutlet UILabel* lbState;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

- (BOOL) shouldCreateEvent;
- (void)closeStreamPickerAndRestorePreviousStreamId;
- (NSString*) getNumericalValueFormatted;
@end

@implementation EventDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UI7NavigationController patchIfNeeded];
    [UI7NavigationItem patchIfNeeded];
    [UI7NavigationBar patchIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenContainerDidChangeFrameNotification:)
                                                 name:JSTokenFieldFrameDidChangeNotification
                                               object:nil];
    self.isInEditMode = self.event.isDraft;
    _isInitialDraft = _event.isDraft;
    _isDateExtHidden = true;
    [self initTags];
    [self initBtDelete];
    [self updateUIForEvent];
    _previousStreamId = [self.event.streamId copy];
    _previousDate = [self.event.eventDate copy];
    //[self.tokendDoneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    
    ZenKeyboard *keyboard = [[ZenKeyboard alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
    [keyboard setTextField:_numericalValue];
    
    if (self.event.isDraft) [self updateUIEditMode:YES];
    else
    {
        [self.navigationItem setHidesBackButton:YES];
        UIBarButtonItem *btbrowse= [[UIBarButtonItem alloc]
                                    initWithTitle: NSLocalizedString(@"Pryv", nil)
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(btBrowsePressed:)];
        self.navigationItem.leftBarButtonItem = btbrowse;
    }
    
    
    // commented for now.. to be reused for share and anther actions.
    // [self initBottomButtonsContainer];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_timePicker) {
        _timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 38, 320, 162)];
        [_timePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_timePicker setHidden:YES];
        [_timePicker setDatePickerMode:UIDatePickerModeTime];
        [_dateExtCell.contentView addSubview:_timePicker];
        NSDate *date = [self.event eventDate];
        if (date == nil) date = [NSDate date];
        [_timePicker setDate:date];
    }
    
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 38, 320, 162)];
        [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_dateExtCell.contentView addSubview:_datePicker];
        NSDate *date = [self.event eventDate];
        if (date == nil) date = [NSDate date];
        [_datePicker setDate:date];
    }
    
}

-(void) initBtDelete
{
    [self.deleteButton.layer setBorderColor:[UIColor colorWithRed:189.0/255.0 green:16.0/255.0 blue:38.0/255.0 alpha:1].CGColor];
    [self.deleteButton.layer setBorderWidth:1];
    self.deleteButton.layer.cornerRadius = 5;
}

#pragma mark - UI update

- (void)updateUIForEvent
{
    EventDataType type = [self.event eventDataType];
    switch (type) {
        case EventDataTypeImage:
            [self updateUIForEventImageType];
            break;
            
        case EventDataTypeValueMeasure:
            [self updateUIForValueEventType];
            break;
            
        case EventDataTypeNote:
            [self updateUIForNoteEventType];
            break;
            
        default:
            break;
    }
    
    NSDate *date = [self.event eventDate];
    if (date == nil) date = [NSDate date];
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:date];
    
    if (_datePicker) [_datePicker setDate:date];
    
    if (_timePicker) [_timePicker setDate:date];
    
    // Auto Set diary stream
    if (! self.autoSetDiaryStream) { // already in autSetMode, happend when open StreamPicker then cancel
        self.autoSetDiaryStream = NO;
        if (! _event.connection) {
            _event.connection = [NotesAppController sharedInstance].connection;
        }
        if (! _event.stream && [NotesAppController sharedInstance].connection) {
            PYStream* found = [PYStream findStreamMatchingId:@"diary"
                                                     orNames:@[@"journal", @"diary", @"me"]
                                                      onList:_event.connection.fetchedStreamsRoots];
            if (found) {
                _event.streamId = found.streamId;
                self.autoSetDiaryStream = YES;
            }
        }
    }
    
    self.streamsLabel.text = [self.event eventBreadcrumbs];
    
    if (_event.duration == 0) {
        [_setRunningView setHidden:YES];
        [_addView setHidden:NO];
    }else{
        [_setRunningView setHidden:NO];
        [_addView setHidden:YES];
    }
    
    [_lbDuration setEventDate:_event.eventDate];
    
    if (_event.stream) [self.pastille setBackgroundColor:[[self.event stream] getColor]];
    
    self.descriptionText.text = self.event.eventDescription;
    
    if([self.streamsLabel.text length] < 1)
    {
        self.streamsLabel.text = NSLocalizedString(@"ViewController.Streams.SelectStream", nil);
    }
    
    if (self.isInEditMode) {
        self.editButton.title = NSLocalizedString(@"Done", nil);
    } else {
        self.editButton.title = NSLocalizedString(@"Edit", nil);
    }
    
    [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}




- (void)updateUIForEventImageType
{
    self.navigationItem.title =  NSLocalizedString(@"DetailViewController.TitlePicture", nil);
    if(self.picture_ImageView.image)
    {
        return;
    }
    [self.event preview:^(UIImage *img) {
        if(self.picture_ImageView.image) return;
        
        [self.tableView beginUpdates];
        self.picture_ImageView.image = img;
        [self.tableView endUpdates];
    } failure:nil];
    
    
    [self.event firstAttachmentAsImage:^(UIImage *image) {
        [self.tableView beginUpdates];
        self.picture_ImageView.image = image;
        [self.tableView endUpdates];
    } errorHandler:nil];
}

-(NSString*) getNumericalValueFormatted{
    NSString *value = NULL;
    if ([self.event.eventContent isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *numf = [[NSNumberFormatter alloc] init];
        [numf setNumberStyle:NSNumberFormatterDecimalStyle];
        if ([[numf stringFromNumber:self.event.eventContent] rangeOfString:@"."].length != 0){
            [numf setMinimumFractionDigits:2];
        }else{
            [numf setMaximumFractionDigits:0];
        }
        
        value = [numf stringFromNumber:self.event.eventContent];
    }else{
        value = self.event.eventContentAsString;
    }
    return value;
}


- (void)updateUIForValueEventType
{
    self.navigationItem.title =  NSLocalizedString(@"DetailViewController.TitleMeasure", nil);
    
    [_numericalValue setKeyboardType:UIKeyboardTypeNumberPad];
    
    NSString *unit = [self.event.pyType symbol];
    NSString *formatDescription = [self.event.pyType localizedName];
    NSString *value = self.getNumericalValueFormatted;
    
    [_numericalValue_TypeLabel setText:formatDescription];
    [_numericalValue_Label setText:unit];
    [_numericalValue setText:value];
    
}

- (void)updateUIForNoteEventType
{
    self.navigationItem.title =  NSLocalizedString(@"DetailViewController.TitleNote", nil);
    self.noteText.text = self.event.eventContentAsString;
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCellType cellType = indexPath.row;
    switch (cellType) {
        case DetailCellTypeValue:
        {
            if([self.event eventDataType] == EventDataTypeValueMeasure) return kValueCellHeight;
            return 0;
        }
            
            
        case DetailCellTypeImage:
        {
            CGFloat height = 0;
            if([self.event eventDataType] == EventDataTypeImage)
            {
                UIImage* image = self.picture_ImageView.image;
                if(image)
                {
                    CGFloat scaleFactor = 320 / image.size.width;
                    height = image.size.height * scaleFactor;
                }
            }
            return height;
        }
            
        case DetailCellTypeNote:
        {
            if([self.event eventDataType] == EventDataTypeNote)
            {
                [_noteCell.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
                if(self.isInEditMode && [self.noteText.text length] == 0) {
                    return kStreamCellHeight+20;
                }
                if ([self.noteText.text length] > 0)
                {
                    return [self heightForNoteTextViewWithString:self.noteText.text];
                }
            }
            
            [_noteCell.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            return 0;
        }
            
            
        case DetailCellTypeTime:
            return kDateCellHeight;
            
        case DetailCellTypeTimeExt:
        {
            if (!_isDateExtHidden)
            {
                [_dateExtCell.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
                return 210;
            }
            [_dateExtCell.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
            return 0;
        }
            
        case DetailCellTypeDescription:
        {
            if(self.isInEditMode && [self.descriptionText.text length] == 0) {
                [_descCell.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
                return kStreamCellHeight+20;
            }
            if ([self.descriptionText.text length] > 0)
            {
                [_descCell.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
                return [self heightForNoteTextViewWithString:self.descriptionText.text];
            }
            [_descCell.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
            return 0;
        }
            
        case DetailCellTypeTags:
        {
            if (self.isInEditMode || (self.event.tags.count > 0)) {
                CGFloat tagHeight = self.tokenField.frame.size.height + 38;
                [_tagsCell.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
                return tagHeight;
            }
            [_tagsCell.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
            return 0;
        }
            
        case DetailCellTypeStreams:
            return kStreamCellHeight;
        
        case DetailCellTypeTimeEnd:
            return kDateCellHeight;
            
        case DetailCellTypeDelete:
        {
            if ([_event isDraft])
                return 0;
            return kDeleteCellHeight;
        }
            
        default:
            break;
    }
    
    return kStreamCellHeight;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailCellType cellType = indexPath.row;
    
    if (cellType == DetailCellTypeImage) return;
    if(!self.isInEditMode) return;
    
    
    if (cellType != DetailCellTypeNote && cellType != DetailCellTypeDescription && cellType != DetailCellTypeTags && cellType != DetailCellTypeValue)
        [self.view endEditing:YES];
    
    if (cellType != DetailCellTypeTime && !_isDateExtHidden){
        _isDateExtHidden = true;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
    switch (cellType) {
        case DetailCellTypeValue:
        {
            [_numericalValue becomeFirstResponder];
        }
            break;
            
        case DetailCellTypeNote:
        {
            [_noteText becomeFirstResponder];
        }
            break;
            
        case DetailCellTypeImage:
            
            break;
        case DetailCellTypeTime:
        {
            _isDateExtHidden = !_isDateExtHidden;
            _isDateExtOwnedByStart=true;
            if (_datePicker) [_datePicker setDate:_event.eventDate];
            if (_timePicker) [_timePicker setDate:_event.eventDate];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            if (!_isDateExtHidden) {
                [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:_dateExtCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
            break;
        case DetailCellTypeDescription:
        {
            [_descriptionText becomeFirstResponder];
        }
            break;
        case DetailCellTypeTags:
        {
            [_tokenField.textField becomeFirstResponder];
        }
            break;
        case DetailCellTypeStreams:
        {
            if(self.streamPickerVC)
            {
                [self closeStreamPicker];
            }
            else
            {
                StreamPickerViewController *streamPickerVC = [[UIStoryboard mainStoryBoard] instantiateViewControllerWithIdentifier:@"StreamPickerViewController_ID"];
                
                [self setupStreamPickerViewController:streamPickerVC];
            }
        }
            break;
            
        case DetailCellTypeTimeEnd:
        {
            if (_isDateExtHidden)
                _isDateExtOwnedByStart=false;
            
            if (!_isDateExtHidden && !_isDateExtOwnedByStart) {
                _isDateExtHidden = !_isDateExtHidden;
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }else
            {
                [[self getActionSheet] showInView:self.view];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    if (_event.duration == 0) {
        switch (buttonIndex) {
            case 0:
            {
                [self setAsRunning];
            }
                break;
                
            case 1:
            {
                [self setEndDate];
            }
                break;
                
            case 2:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
    
    if (_event.duration < 0) {
        switch (buttonIndex) {
            case 0:
            {
                
            }
                break;
                
            case 1:
            {
                
            }
                break;
                
            case 2:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
    
    if (_event.duration > 0) {
        switch (buttonIndex) {
            case 0:
            {
                
            }
                break;
                
            case 1:
            {
                
            }
                break;
                
            case 2:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
}

-(void) setAsRunning
{
    [_lbDuration start];
    _event.duration = -1;
    [_setRunningView setHidden:NO];
    [_addView setHidden:YES];
}

-(void) setEndDate
{
    [_setRunningView setHidden:NO];
    [_addView setHidden:YES];
    [_lbDuration stop];
    _event.duration = [[NSDate date] timeIntervalSinceDate:_event.eventDate];
    _isDateExtHidden = !_isDateExtHidden;
    if (_datePicker) [_datePicker setDate:[_event.eventDate dateByAddingTimeInterval:_event.duration]];
    if (_timePicker) [_timePicker setDate:[_event.eventDate dateByAddingTimeInterval:_event.duration]];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:_dateExtCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - IBActions, segue

-(void) btBrowsePressed:(id)sender
{
    if (!_previousStreamId || ![_previousStreamId isEqualToString:_event.streamId] || _isInitialDraft)
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidAddStreamNotification object:[self event]];
    else if ([_previousDate compare:_event.eventDate] != NSOrderedSame)
        [[NSNotificationCenter defaultCenter] postNotificationName:kBrowserShouldScrollToEvent object:[self event]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kShowImagePreviewSegue]) {
        ImageViewController* imvc = [segue destinationViewController];
        [imvc setImage:self.picture_ImageView.image];
    }
}

-(IBAction)valueTextFieldDidChange:(id)sender
{
    self.shouldUpdateEvent=true;
    _event.eventContent = _numericalValue.text;
}

-(void)datePickerValueChanged:(id)sender
{
    if (_isDateExtOwnedByStart) {
        self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:_datePicker.date];
        [_timePicker setDate:_datePicker.date];
        [_event setEventDate:_datePicker.date];

    }else
    {
        _lbState.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:_datePicker.date];
        [_timePicker setDate:_datePicker.date];
        NSTimeInterval duration = [_datePicker.date timeIntervalSinceDate:_event.eventDate];
        [_lbDuration setEndDate:_datePicker.date];
        [_event setDuration:duration];
    }
    
    self.shouldUpdateEvent=true;
}

-(void)timePickerValueChanged:(id)sender
{
    if (_isDateExtOwnedByStart) {
        self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:_timePicker.date];
        [_datePicker setDate:_timePicker.date];
        [_event setEventDate:_timePicker.date];
        self.shouldUpdateEvent=true;
    }else
    {
        _lbState.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:_timePicker.date];
        [_datePicker setDate:_timePicker.date];
        NSTimeInterval duration = [_timePicker.date timeIntervalSinceDate:_event.eventDate];
        [_lbDuration setEndDate:_timePicker.date];
        [_event setDuration:duration];
    }
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [_datePicker setHidden:NO];
        [_timePicker setHidden:YES];
    }
    else{
        [_timePicker setHidden:NO];
        [_datePicker setHidden:YES];
    }
}

- (IBAction)deleteButtonTouched:(id)sender {
    NSString* title = NSLocalizedString(@"Alert.Message.DeleteConfirmation", nil);
    if(self.shouldCreateEvent)
    {
        title = NSLocalizedString(@"Alert.Message.CancelConfirmation", nil);
    }
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            
            [self deleteEvent];
        }
    }];
}

- (void)cancelButtonTouched:(id)sender
{
    if (self.event.isDraft) [self.navigationController popViewControllerAnimated:YES];
    else
    {
        if (self.initialEventValue) [self.event resetFromCachingDictionary:self.initialEventValue];
        
        [self updateUIForEvent];
        self.shouldUpdateEvent = NO;
        [self updateUIEditMode:false];
    }
}

- (IBAction)editButtonTouched:(id)sender
{
    if (_isInEditMode && (_event.stream == nil || _event.streamId == nil)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.DetailViewController.NoStream", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    if (_event.eventDataType != EventDataTypeImage && (!_event.eventContent || [_event.eventContentAsString isEqualToString:@""])) {
        
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
    
    [self updateUIEditMode:!self.isInEditMode];
}

-(void) updateUIEditMode:(BOOL)edit
{
    [self.tableView beginUpdates];
    self.isInEditMode = edit;
    if (edit) [self switchToEditingMode];
    else [self switchFromEditingMode];
    
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:self.isInEditMode];
    }];
    [self.tableView endUpdates];
}

- (void)switchFromEditingMode
{
    [self.view endEditing:YES];
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *btbrowse= [[UIBarButtonItem alloc]
                                initWithTitle: NSLocalizedString(@"Pryv", nil)
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(btBrowsePressed:)];
    self.navigationItem.leftBarButtonItem = btbrowse;
    
    _isDateExtHidden = true;
    
    if ([self.event eventDataType] == EventDataTypeValueMeasure) [_numericalValue setEnabled:NO];
    if ([self.event eventDataType] == EventDataTypeNote) [_noteText setEditable:NO];
    [_descriptionText setEditable:NO];
    
    /*if([self.descriptionText.text isEqualToString:NSLocalizedString(@"ViewController.TextDescriptionContent.TapToAdd", nil)])
     {
     self.descriptionText.text = @"";
     }*/
    if(self.streamPickerVC)
    {
        [self closeStreamPicker];
    }
    
    if(self.shouldCreateEvent)
    {
        [self saveEvent];
    } else if(self.shouldUpdateEvent)
    {
        [self eventSaveModifications];
    }
    
    [self updateLabelsTextColorForEditingMode:NO];
    
    [self.tokenField setUserInteractionEnabled:NO];
    
    //[self switchBtSelectionMode:UITableViewCellSelectionStyleNone];
    
    self.editButton.title = NSLocalizedString(@"Edit", nil);
    
}

- (void)switchToEditingMode
{
    self.initialEventValue = [self.event cachingDictionary];
    
    [_descriptionText setEditable:YES];
    
    if ([self.event eventDataType] == EventDataTypeValueMeasure)
    {
        [_numericalValue setEnabled:YES];
        if (_event.isDraft) [_numericalValue becomeFirstResponder];
    }
    
    if ([self.event eventDataType] == EventDataTypeNote)
    {
        [_noteText setEditable:YES];
        if (_event.isDraft) [_noteText becomeFirstResponder];
    }
    
    
    /*if([self.descriptionText.text length] == 0)
     {
     self.descriptionText.text = NSLocalizedString(@"ViewController.TextDescriptionContent.TapToAdd", nil);
     
     }*/
    
    [self.tokenField setUserInteractionEnabled:YES];
    //[self switchBtSelectionMode:UITableViewCellSelectionStyleBlue];
    
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *btbrowse= [[UIBarButtonItem alloc]
                                initWithTitle: NSLocalizedString(@"Cancel", nil)
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(cancelButtonTouched:)];
    self.navigationItem.leftBarButtonItem = btbrowse;
    self.editButton.title = NSLocalizedString(@"Done", nil);
    
}

-(void) switchBtSelectionMode:(UITableViewCellSelectionStyle)status{
    for (int i=0; i<[self.tableView numberOfRowsInSection:0]-1; i++) {
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]] setSelectionStyle:status];
    }
    
}

- (void)updateLabelsTextColorForEditingMode:(BOOL)isEditingMode
{
    UIColor *textColor = [UIColor blackColor];
    if(isEditingMode)
    {
        textColor = [UIColor blackColor];
    }
    
    self.noteText.textColor = textColor;
    self.timeLabel.textColor = textColor;
    //self.tagsLabel.textColor = textColor;
    self.descriptionText.textColor = textColor;
    self.streamsLabel.textColor = textColor;
}

#pragma mark - Edit methods

- (void)setupStreamPickerViewController:(StreamPickerViewController*)streamPickerVC
{
    if (self.autoSetDiaryStream) {
        streamPickerVC.stream = nil;
    } else {
        streamPickerVC.stream = [self.event stream];
    }
    streamPickerVC.delegate = self;
    self.streamPickerVC = streamPickerVC;
    [self.navigationController presentViewController:streamPickerVC animated:YES completion:nil];
}

- (void)closeStreamPickerAndRestorePreviousStreamId
{
    if (self.previousStreamId) {
        self.event.streamId = self.previousStreamId;
    }
}

#pragma mark - StreamPickerDelegate methods


- (void)streamPickerDidSelectStream:(PYStream *)stream
{
    self.autoSetDiaryStream = NO;
    if (self.event.connection == nil) {
        self.event.connection = stream.connection;
    }
    if (self.event.connection != stream.connection) {
        NSLog(@"<ERROR> EventDetailsViewController.streamPickerDidSelectStream cannot move an event to another connection");
    } else {
        self.event.streamId = stream.streamId;
        self.shouldUpdateEvent = YES;
    }
}

- (void)closeStreamPicker
{
    [self updateUIForEvent];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        self.streamPickerVC = nil;
    }];
}

- (void)cancelStreamPicker
{
    [self closeStreamPickerAndRestorePreviousStreamId];
    [self closeStreamPicker];
}

#pragma mark - Utils

-(UIActionSheet*)getActionSheet
{
    UIActionSheet *actionSheet;
    if (_event.duration == 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detail.AddDuration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Detail.SetAsRunning", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    if (_event.duration < 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detail.AddDuration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Detail.StopNow", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    if (_event.duration > 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detail.AddDuration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Detail.SetAsRunning", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    return actionSheet;
}

-(CGFloat) heightForNoteTextViewWithString:(NSString*)s
{
    NSDictionary *attributes = @{NSFontAttributeName: self.noteText.font};
    CGRect rect = [s boundingRectWithSize:CGSizeMake(kNoteTextViewWidth-10, CGFLOAT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:attributes
                                  context:nil];
    if ([s characterAtIndex:s.length-1]=='\n')
        rect.size.height += 20;
    
    NSLog(@"%f", rect.size.height);
    return rect.size.height+56 ;
}

- (BOOL) shouldCreateEvent
{
    return (self.event.eventId == nil);
}

-(MMDrawerController*)mm_drawerController{
    
    return (MMDrawerController*)[[[[UIApplication sharedApplication] delegate] window]rootViewController];
}

- (void)saveEvent
{
    //[self showLoadingOverlay];
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         
         [connection eventCreate:self.event andCacheFirst:YES
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event)
          {
              [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidCreateEventNotification object:[self event]];
              
              BOOL shouldTakePictureFlag = NO;
              if([self.event eventDataType] == EventDataTypeImage)
              {
                  shouldTakePictureFlag = self.imagePickerType == UIImagePickerControllerSourceTypeCamera;
              }
              [[DataService sharedInstance] saveEventAsShortcut:self.event andShouldTakePictureFlag:shouldTakePictureFlag];
              [self.tableView beginUpdates];
              [self.tableView endUpdates];
              
              //[self hideLoadingOverlay];
          } errorHandler:^(NSError *error) {
              //[self hideLoadingOverlay];
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
             [self hideLoadingOverlay];
         }];
         
     }];
}

- (void)eventSaveModifications
{
    //[self showLoadingOverlay];
    [NotesAppController sharedConnectionWithID:nil
                   noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         [connection eventSaveModifications:self.event successHandler:^(NSString *stoppedId)
          {
              //[self hideLoadingOverlay];
          } errorHandler:^(NSError *error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
              //[self hideLoadingOverlay];
          }];
     }];
}

- (void)shareEvent
{
    NSLog(@"SHARE EVENT");
}

#pragma mark - JSTOkenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    return NO;
}

- (void)tokenFieldWillBeginEditing:(JSTokenField *)tokenField
{
    _isDateExtHidden = true;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField
{
    [self.tokenField updateTokensInTextField:self.tokenField.textField];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in self.tokenField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.event.tags = tokens;
    self.shouldUpdateEvent = YES;
}

- (void)initTags
{
    self.tokenField.delegate = self;
    //[self.tokendDoneButton setHidden:YES];
    for(NSString *tag in self.event.tags)
    {
        [self.tokenField addTokenWithTitle:tag representedObject:tag];
    }
}

- (void)tokenContainerDidChangeFrameNotification:(NSNotification*)note
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _isDateExtHidden = true;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    return _isInEditMode;
}

- (void) textViewDidChange:(UITextView *)textView
{
    _shouldUpdateEvent = true;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    if (textView == _noteText) _event.eventContent = _noteText.text;
    else if (textView == _descriptionText) _event.eventDescription = _descriptionText.text;
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:DetailCellTypeTags inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    //self.tagDoneButtonConstraint.constant = 68;
    //[self.tokendDoneButton setHidden:NO];
    //[self.view setNeedsLayout];
    /*[UIView animateWithDuration:0.25 animations:^{
     [self.view layoutIfNeeded];
     }];*/
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSInteger rowToSelect = 0;
    if([self.event eventDataType] == EventDataTypeImage)
    {
        rowToSelect = DetailCellTypeImage;
    }
    else if([self.event eventDataType] == EventDataTypeNote)
    {
        rowToSelect = DetailCellTypeNote;
    }
    else
    {
        rowToSelect = DetailCellTypeValue;
    }
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    //self.tagDoneButtonConstraint.constant = 0;
    //[self.tokendDoneButton setHidden:YES];
    //[self.tableView reloadData];
    /*[self.view setNeedsLayout];
     [UIView animateWithDuration:0.25 animations:^{
     [self.view layoutIfNeeded];
     } completion:^(BOOL finished) {
     
     }];*/
}

@end
