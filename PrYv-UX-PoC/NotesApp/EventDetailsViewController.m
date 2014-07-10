//
//  EventDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "BaseDetailCell.h"
#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>
#import <PryvApiKit/PYConnection+DataManagement.h>
#import "TextEditorViewController.h"
#import "DatePickerViewController.h"
#import "AddNumericalValueViewController.h"
#import "StreamPickerViewController.h"
#import "DataService.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"
#import "DetailsBottomButtonsContainer.h"
#import "UIAlertView+PrYv.h"
#import "ImagePreviewViewController.h"
#import "ImageViewController.h"
#import "NotesAppController.h"
#import "MMDrawerController.h"
#import "MenuNavController.h"

#define kLineCellHeight 54
#define kValueCellHeight 100
#define kImageCellHeight 320
#define kNoteTextViewWidth 297

#define kShowValueEditorSegue @"ShowValueEditorSegue_ID"
#define kShowImagePreviewSegue @"ShowImagePreviewSegue_ID"
#define kShowNoteEditorSegue @"ShowNoteEditorSegue_ID"
#define kShowDatePickerSegue @"kShowDatePickerSegue_ID"
#define kShowDescriptionEditorSegue @"ShowDescriptionEditorSegue_ID"
#define isiPhone5 ([UIScreen mainScreen].bounds.size.height == 568.0f)

typedef enum
{
    DetailCellTypeValue,
    DetailCellTypeImage,
    DetailCellTypeNote,
    DetailCellTypeStreams,
    DetailCellTypeTime,
    DetailCellTypeTimeExt,
    DetailCellTypeTags,
    DetailCellTypeDescription,
    DetailCellTypeDelete
    
} DetailCellType;

@interface EventDetailsViewController () <StreamsPickerDelegate, JSTokenFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *previousStreamId;
@property (nonatomic, strong) NSDictionary *initialEventValue;

@property (nonatomic) BOOL isStreamExpanded;
@property (nonatomic) BOOL isTagExpanded;
@property (nonatomic) BOOL isDateExtHidden;
@property (nonatomic) BOOL isInEditMode;
@property (nonatomic) BOOL shouldUpdateEvent;

@property (nonatomic, strong) StreamPickerViewController *streamPickerVC;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;


// -- specific properties

@property (nonatomic, weak) IBOutlet UIImageView *picture_ImageView;

@property (nonatomic, weak) IBOutlet UILabel *numericalValue_Label;
@property (nonatomic, weak) IBOutlet UILabel *numericalValue_TypeLabel;

@property (nonatomic, weak) IBOutlet UITextView *noteText;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionText;

// -- common properties

@property (nonatomic, weak) IBOutlet UIView *pastille;
@property (nonatomic, weak) IBOutlet JSTokenField *tokenField;
@property (nonatomic, weak) IBOutlet UIButton *tokendDoneButton;
@property (nonatomic, weak) IBOutlet UIView *tokenContainer;
@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;
@property (nonatomic, strong) DetailsBottomButtonsContainer *bottomButtonsContainer;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIDatePicker *timePicker;


@property (strong, nonatomic) IBOutlet UIButton *deleteButton;


// -- constraints

//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagDoneButtonConstraint;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint1;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint2;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint3;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *noteLabelConstraint1;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *noteLabelConstraint2;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *noteLabelConstraint3;
/*@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint2;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint3;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint4;*/
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;


- (BOOL) shouldCreateEvent;
- (CGFloat) heightForNoteTextViewWithString:(NSString*)s;
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
    _isDateExtHidden = true;
    //[self initNoteTextView];
    [self initTags];
    [self initBtDelete];
    [self updateUIForEvent];
    [self.tokendDoneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    
    if (self.event.isDraft) [self updateUIEditMode:YES];
    
    // commented for now.. to be reused for share and anther actions.
    // [self initBottomButtonsContainer];
}

-(void) initNoteTextView
{
    float height = [self heightForNoteTextViewWithString:self.event.eventContentAsString];
    CGRect textViewRect = CGRectMake(10, 10, kNoteTextViewWidth, height);
    
    self.noteText.frame = textViewRect;
    self.noteText.contentSize = CGSizeMake(kNoteTextViewWidth, height);
}

-(void) initBtDelete
{
    [self.deleteButton.layer setBorderColor:[UIColor colorWithRed:189.0/255.0 green:16.0/255.0 blue:38.0/255.0 alpha:1].CGColor];
    [self.deleteButton.layer setBorderWidth:1];
    self.deleteButton.layer.cornerRadius = 5;
}

/*- (void)initBottomButtonsContainer
{
    __block EventDetailsViewController *weakSelf = self;
    self.bottomButtonsContainer = [[[UINib nibWithNibName:@"DetailsBottomButtonsContainer" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.bottomButtonsContainer setShareButtonTouchHandler:^(UIButton *shareButton) {
        [weakSelf shareEvent];
    }];
    [self.bottomButtonsContainer setDeleteButtonTouchHandler:^(UIButton *deleteButton) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Message.DeleteConfirmation", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(alertView.cancelButtonIndex != buttonIndex)
            {
                [weakSelf deleteEvent];
            }
        }];
    }];
    CGRect frame = self.bottomButtonsContainer.frame;
    frame.origin.y = self.tableView.frame.size.height - 64 - self.bottomButtonsContainer.frame.size.height;
    if(![UIDevice isiOS7Device])
    {
        frame.origin.y+=20;
    }
    self.bottomButtonsContainer.frame = frame;
    [self.view addSubview:self.bottomButtonsContainer];
    [self.view bringSubviewToFront:self.bottomButtonsContainer];
}*/

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.bottomButtonsContainer.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.bottomButtonsContainer.frame.size.height;
    self.bottomButtonsContainer.frame = frame;
    [self.view bringSubviewToFront:self.bottomButtonsContainer];
}*/

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
    
    [_datePicker setDate:date];
    [_timePicker setDate:date];
    
    
    self.streamsLabel.text = [self.event eventBreadcrumbs];
    [self.pastille setBackgroundColor:[[self.event stream] getColor]];
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
    if(self.event.isDraft && !self.event.type)
    {
        self.numericalValue_Label.text = @"";
        self.numericalValue_TypeLabel.text = @"";
        return;
    }
    NSString *unit = [self.event.pyType symbol];
    
    NSString *formatDescription = [self.event.pyType localizedName];
    
    if (! unit) {
        unit = formatDescription ;
        [self.numericalValue_TypeLabel setText:@""];
    } else {
        [self.numericalValue_TypeLabel setText:formatDescription];
    }
    
    
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",self.getNumericalValueFormatted, unit];
    
    [self.numericalValue_Label setText:value];
    
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
                if(self.isInEditMode && [self.noteText.text length] == 0) {
                    return kLineCellHeight;
                }
                if ([self.noteText.text length] > 0)
                {
                    return [self heightForNoteTextViewWithString:self.noteText.text];
                }
            }
            return 0;
        }
            
            
        case DetailCellTypeTime:
            return kLineCellHeight;
        
        case DetailCellTypeTimeExt:
        {
            if (_isDateExtHidden) return 0;
            return 210;
        }
            
        case DetailCellTypeDescription:
        {
            if(self.isInEditMode && [self.descriptionText.text length] == 0) {
                return kLineCellHeight+20;
            }
            if ([self.descriptionText.text length] > 0)
            {
                return [self heightForNoteTextViewWithString:self.descriptionText.text]+18;
            }
            return 0;
        }
            
        case DetailCellTypeTags:
        {
            if (self.isInEditMode || (self.event.tags.count > 0)) {
                CGFloat tagHeight = self.tokenField.frame.size.height + 28;
                return tagHeight;
            }
            return 0;
        }
            
        case DetailCellTypeStreams:
            return kLineCellHeight;
            
        case DetailCellTypeDelete:
        {
            if ([self shouldCreateEvent] || ![self isInEditMode])
                return 0;
            return kLineCellHeight;
        }
            
            
        default:
            break;
    }
    
    return kLineCellHeight;
}

#pragma mark - UITableViewDeleagate methods

/*- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self heightForCellAtIndexPath:indexPath withEvent:self.event];
    cell.alpha = height > 0 ? 1.0f : 0.0f;
}*/

/**
 - (void)showImagePreview:(id)sender
 {
 
 ImagePreviewViewController* imagePreviewVC = (ImagePreviewViewController *)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"ImagePreviewViewController_ID"];
 imagePreviewVC.image = self.picture_ImageView.image;
 //imagePreviewVC.descText = self.eventDescriptionLabel.text;
 [self.navigationController pushViewController:imagePreviewVC animated:YES];
 }**/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailCellType cellType = indexPath.row;
    if (cellType != DetailCellTypeTime) _isDateExtHidden = true;
    if (cellType == DetailCellTypeImage) {
        ImageViewController *imagePreview = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
        imagePreview.image = self.picture_ImageView.image;
        [self presentViewController:imagePreview animated:YES completion:nil];
        //[self performSegueWithIdentifier:kShowImagePreviewSegue sender:nil];
        return;
    }
    
    if(!self.isInEditMode)
    {
        return;
    }
    
    switch (cellType) {
        case DetailCellTypeValue:
            
            break;
        case DetailCellTypeImage:
            
            break;
        case DetailCellTypeTime:
        {
            _isDateExtHidden = !_isDateExtHidden;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }
            break;
        case DetailCellTypeDescription:
            break;
        case DetailCellTypeTags:
            
            break;
        case DetailCellTypeStreams:
        {
            if(self.streamPickerVC)
            {
                [self closeStreamPicker];
            }
            else
            {
                StreamPickerViewController *streamPickerVC = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"StreamPickerViewController_ID"];
                
                [self setupStreamPickerViewController:streamPickerVC];
            }
        }
            break;
        
        case DetailCellTypeDelete:
            break;
        default:
            break;
    }
}

#pragma mark - Actions

-(IBAction)datePickerValueChanged:(id)sender
{
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:_datePicker.date];
    [_timePicker setDate:_datePicker.date];
}

-(IBAction)timePickerValueChanged:(id)sender
{
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:_timePicker.date];
    [_datePicker setDate:_timePicker.date];
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
    
    [self updateUIEditMode:!self.isInEditMode];
    /*if(self.isInEditMode)
    {
        // -- if streamPickerVC is opened
        if(self.streamPickerVC)
        {
            [self closeStreamPicker];
            return;
        }
        
        if(!self.event.streamId && sender)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ViewController.Streams.SelectStream", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        [self switchFromEditingMode];
    }
    else
    {
        // take a snapshot of event's value
        self.initialEventValue = [self.event cachingDictionary];
        [self switchToEditingMode];
    }
    self.isInEditMode = !self.isInEditMode;
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:self.isInEditMode];
    }];*/
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
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:NO];
    
    _isDateExtHidden = true;
    [self.view endEditing:YES];
    [_noteText setEditable:NO];
    [_descriptionText setEditable:NO];
    
    if([self.descriptionText.text isEqualToString:NSLocalizedString(@"ViewController.TextDescriptionContent.TapToAdd", nil)])
    {
        self.descriptionText.text = @"";
    }
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
    /**
     else
     {
     [self.navigationController popViewControllerAnimated:YES];
     }**/
    
    [self updateLabelsTextColorForEditingMode:NO];
    
    [self.tokenField setUserInteractionEnabled:NO];
    
    [self switchBtSelectionMode:UITableViewCellSelectionStyleNone];
    
    self.editButton.title = NSLocalizedString(@"Edit", nil);
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.tableView
                          duration:0.1f
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^(void) {
                            [self.tableView reloadData];
                        } completion:NULL];
        
    });*/
    /*[UIView animateWithDuration:2.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tagsLabel.alpha = 1.0f;
        self.tokenContainer.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];*/
}

- (void)switchToEditingMode
{
    self.initialEventValue = [self.event cachingDictionary];
    
    [_noteText setEditable:YES];
    [_descriptionText setEditable:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: NSLocalizedString(@"Cancel", nil)
                                   style: UIBarButtonItemStyleBordered
                                   target:self action: @selector(cancelButtonTouched:)];
    
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setHidesBackButton:YES];
    
    if([self.descriptionText.text length] == 0)
    {
        self.descriptionText.text = NSLocalizedString(@"ViewController.TextDescriptionContent.TapToAdd", nil);
        
    }
    
    [self.tokenField setUserInteractionEnabled:YES];
    
    // change selection style but delete cell
    [self switchBtSelectionMode:UITableViewCellSelectionStyleBlue];
    
    self.editButton.title = NSLocalizedString(@"Done", nil);
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.tableView
                          duration:10.2f
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^(void) {
                            [self.tableView reloadData];
                        } completion:NULL];
        
    });*/
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    /*[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tagsLabel.alpha = 0.0f;
        self.tokenContainer.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];*/
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if([identifier isEqualToString:kShowNoteEditorSegue])
    {
        [self setupNoteContentEditorViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowDescriptionEditorSegue])
    {
        [self setupDescriptionEditorViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowImagePreviewSegue])
    {
        [self setupImagePreviewViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowValueEditorSegue])
    {
        [self setupAddNumericalValueViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowDatePickerSegue])
    {
        [self setupDatePickerViewController:segue.destinationViewController];
    }
}

#pragma mark - Edit methods

- (void)setupDescriptionEditorViewController:(TextEditorViewController*)textEditorVC
{
    textEditorVC.textDidChangeCallBack = ^(NSString* text, TextEditorViewController* textEdit) {
        if (self.event.eventDescription && [text isEqualToString:self.event.eventDescription]) return;
        self.event.eventDescription = text;
        
        self.shouldUpdateEvent = YES;
        //[self updateUIForEvent];
    };
    textEditorVC.text = self.event.eventDescription ? self.event.eventDescription : @"";
}



- (void)setupNoteContentEditorViewController:(TextEditorViewController*)textEditorVC
{
    textEditorVC.textDidChangeCallBack = ^(NSString* text, TextEditorViewController* textEdit) {
        if (self.event.eventContentAsString && [text isEqualToString:self.event.eventContentAsString]) return;
        self.event.eventContent = text;
        self.shouldUpdateEvent = YES;
        //[self updateUIForEvent];
    };
    textEditorVC.text = self.event.eventContent ? self.event.eventContentAsString : @"";
}

- (void)setupDatePickerViewController:(DatePickerViewController *)dpVC
{
    NSDate *date = [self.event eventDate];
    if(!date)
    {
        date = [NSDate date];
    }
    dpVC.selectedDate = date;
    [dpVC setDateDidChangeBlock:^(NSDate *newDate, DatePickerViewController *dp) {
        if([newDate timeIntervalSince1970] == [[self.event eventDate] timeIntervalSince1970]) return;
        [self.event setEventDate:newDate];
        self.shouldUpdateEvent = YES;
        //[self updateUIForEvent];
    }];
}

- (void)setupImagePreviewViewController:(ImagePreviewViewController*)imagePreviewVC
{
    
    imagePreviewVC.image = self.picture_ImageView.image;
    imagePreviewVC.descText = self.event.eventDescription;
}

- (void)setupAddNumericalValueViewController:(AddNumericalValueViewController*)addNumericalValueVC
{
    if(self.event.type)
    {
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            addNumericalValueVC.value = self.getNumericalValueFormatted;
            //addNumericalValueVC.value = self.event.eventContentAsString;
            addNumericalValueVC.valueClass = [components objectAtIndex:0];
            addNumericalValueVC.valueType = [components objectAtIndex:1];
        }
    }
    [addNumericalValueVC setValueDidChangeBlock:^(NSString* valueClass, NSString *valueType, NSString* value, AddNumericalValueViewController *addNumericalVC) {
        self.event.eventContent = value;
        self.event.type = [NSString stringWithFormat:@"%@/%@",valueClass,valueType];
        self.shouldUpdateEvent = YES;
        //[self updateUIForEvent];
    }];
}

- (void)setupStreamPickerViewController:(StreamPickerViewController*)streamPickerVC
{
    self.previousStreamId = [self.event.streamId copy];
    streamPickerVC.stream = [self.event stream];
    streamPickerVC.delegate = self;
    self.streamPickerVC = streamPickerVC;
    //[self.streamPickerVC.view.subviews[0] removeFromSuperview];
    //CGPoint center = self.streamPickerVC.view.center;
    //self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:streamPickerVC animated:YES completion:nil];
    /*[self.navigationController presentViewController:self.streamPickerVC animated:YES completion:^{
        self.streamPickerVC.view.center = CGPointMake(self.streamPickerVC.view.center.x, self.streamPickerVC.view.center.y + self.view.bounds.size.height);
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.streamPickerVC.view.center = center;
        } completion:^(BOOL finished) {
            
        }];
    }nil];*/
    
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

-(CGFloat) heightForNoteTextViewWithString:(NSString*)s
{
    NSDictionary *attributes = @{NSFontAttributeName: self.noteText.font};
    CGRect rect = [s boundingRectWithSize:CGSizeMake(kNoteTextViewWidth-10, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    return rect.size.height+40 ;
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
         
         [connection eventCreate:self.event
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event)
          {
              [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidCreateEventNotification object:[self event]];
              
              BOOL shouldTakePictureFlag = NO;
              if([self.event eventDataType] == EventDataTypeImage)
              {
                  shouldTakePictureFlag = self.imagePickerType == UIImagePickerControllerSourceTypeCamera;
              }
              [[DataService sharedInstance] saveEventAsShortcut:self.event andShouldTakePictureFlag:shouldTakePictureFlag];
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
    [self showLoadingOverlay];
    
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


#pragma mark - Tags

- (IBAction)tokenDoneButtonTouched:(id)sender
{
    [self.tokenField.textField resignFirstResponder];
    [self.tokenField updateTokensInTextField:self.tokenField.textField];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in self.tokenField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.event.tags = tokens;
    //[self updateTagsLabel];
    self.shouldUpdateEvent = YES;
}

#pragma mark - JSTOkenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    //[self updateTagsLabel];
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

}

- (void)initTags
{
    self.tokenField.delegate = self;
    [self.tokendDoneButton setHidden:YES];
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
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:DetailCellTypeTags inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    //self.tagDoneButtonConstraint.constant = 68;
    [self.tokendDoneButton setHidden:NO];
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
    [self.tokendDoneButton setHidden:YES];
    //[self.tableView reloadData];
    /*[self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
     
    }];*/
}

@end
