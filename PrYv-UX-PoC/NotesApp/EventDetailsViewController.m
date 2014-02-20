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
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>
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

#define kLineCellHeight 54
#define kValueCellHeight 100
#define kImageCellHeight 320

#define kShowValueEditorSegue @"ShowValueEditorSegue_ID"
#define kShowImagePreviewSegue @"ShowImagePreviewSegue_ID"
#define kShowNoteEditorSegue @"ShowNoteEditorSegue_ID"
#define kShowDatePickerSegue @"kShowDatePickerSegue_ID"
#define kShowDescriptionEditorSegue @"ShowDescriptionEditorSegue_ID"

typedef NS_ENUM(NSUInteger, DetailCellType)
{
    DetailCellTypeValue,
    DetailCellTypeImage,
    DetailCellTypeNote,
    DetailCellTypeTime,
    DetailCellTypeStreams,
    DetailCellTypeTags,
    DetailCellTypeDescription,
    DetailCellTypeSpacer
};

@interface EventDetailsViewController () <StreamsPickerDelegate,JSTokenFieldDelegate>

@property (nonatomic) BOOL isStreamExpanded;
@property (nonatomic) BOOL isTagExpanded;

@property (nonatomic) BOOL isInEditMode;
@property (nonatomic) BOOL shouldUpdateEvent;

@property (nonatomic, strong) StreamPickerViewController *streamPickerVC;
@property (nonatomic) EventDataType eventDataType;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;


// -- specific properties

@property (nonatomic, weak) IBOutlet UIImageView *picture_ImageView;

@property (nonatomic, weak) IBOutlet UILabel *numericalValue_Label;
@property (nonatomic, weak) IBOutlet UILabel *numericalValue_TypeLabel;

@property (nonatomic, weak) IBOutlet UILabel *note_Label;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

// -- common properties

@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet JSTokenField *tokenField;
@property (nonatomic, weak) IBOutlet UIButton *tokendDoneButton;
@property (nonatomic, weak) IBOutlet UIView *tokenContainer;
@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;
@property (nonatomic, strong) DetailsBottomButtonsContainer *bottomButtonsContainer;


@property (strong, nonatomic) IBOutlet UIButton *deleteButton;


// -- constraints

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagDoneButtonConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint2;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint3;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint2;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint3;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagConstraint4;


- (BOOL) shouldCreateEvent;

@end

@implementation EventDetailsViewController

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
    
    [UI7NavigationController patchIfNeeded];
    [UI7NavigationItem patchIfNeeded];
    [UI7NavigationBar patchIfNeeded];
    
    if(self.event)
    {
        [self updateEventDataType];
    }
    
    [self initTags];
    [self updateUIForEvent];
    
    self.isInEditMode = NO;
    
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
    
    if(self.event.isDraft)
    {
        [self editButtonTouched:nil];
    }
    
    [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    
    // commented for now.. to be reused for share and anther actions.
    // [self initBottomButtonsContainer];
}

- (void)updateUIForCurrentEvent
{
    [self updateUIForEvent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
}

- (BOOL)shouldAnimateViewController:(UIViewController *)vc
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEventDataType
{
    if(self.event.isDraft && !self.event.type)
    {
        self.eventDataType = EventDataTypeValueMeasure;
    }
    else
    {
        self.eventDataType = [_event eventDataType];
    }
}

- (void)initBottomButtonsContainer
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
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.bottomButtonsContainer.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.bottomButtonsContainer.frame.size.height;
    self.bottomButtonsContainer.frame = frame;
    [self.view bringSubviewToFront:self.bottomButtonsContainer];
}

#pragma mark - UI update

- (void)updateUIForEvent
{
    if(self.eventDataType == EventDataTypeImage)
    {
        [self updateUIForEventImageType];
    }
    else if(self.eventDataType == EventDataTypeValueMeasure)
    {
        [self updateUIForValueEventType];
    }
    else if(self.eventDataType == EventDataTypeNote)
    {
        [self updateUIForNoteEventType];
    }
    
    NSDate *date = [self.event eventDate];
    if (date == nil) date = [NSDate date]; // now
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:date];
    self.streamsLabel.text = [self.event eventBreadcrumbsForStreamsList:self.streams];
    self.descriptionLabel.text = self.event.eventDescription;
    
    if([self.streamsLabel.text length] < 1)
    {
        self.streamsLabel.text = NSLocalizedString(@"ViewController.Streams.SelectStream", nil);
    }
    [self updateTagsLabel];
    [self.tableView reloadData];
}




- (void)updateUIForEventImageType
{
    
    [self.event firstAttachmentAsImage:^(UIImage *image) {
        self.picture_ImageView.image = image;
    } errorHandler:nil];
}




- (void)updateUIForValueEventType
{
    if(self.event.isDraft && !self.event.type)
    {
        self.numericalValue_Label.text = @"";
        self.numericalValue_TypeLabel.text = @"";
        return;
    }
    NSString *unit = [self.event.pyType symbol];
    if (! unit) { unit = self.event.pyType.formatKey ; }
    
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[self.event.eventContent description], unit];
    [self.numericalValue_Label setText:value];
    
    NSString *formatDescription = [self.event.pyType localizedName];
    if (! formatDescription) { unit = self.event.pyType.key ; }
    [self.numericalValue_TypeLabel setText:formatDescription];
}

- (void)updateUIForNoteEventType
{
    self.note_Label.text = self.event.eventContent;
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndexPath:indexPath withEvent:self.event];
}

#pragma mark - UITableViewDeleagate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self heightForCellAtIndexPath:indexPath withEvent:self.event];
    cell.alpha = height > 0 ? 1.0f : 0.0f;
}


- (void)showImagePreview:(id)sender
{
    ImagePreviewViewController* imagePreviewVC = (ImagePreviewViewController *)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"ImagePreviewViewController_ID"];
    imagePreviewVC.image = self.picture_ImageView.image;
    //imagePreviewVC.descText = self.eventDescriptionLabel.text;
    [self.navigationController pushViewController:imagePreviewVC animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCellType cellType = indexPath.row;
    if (cellType == DetailCellTypeImage) {
        [self performSegueWithIdentifier:kShowImagePreviewSegue sender:nil];
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
            
            break;
        case DetailCellTypeDescription:
            break;
        case DetailCellTypeTags:
            
            break;
        case DetailCellTypeStreams:
        {
            StreamPickerViewController *streamPickerVC = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"StreamPickerViewController_ID"];
            [self setupStreamPickerViewController:streamPickerVC];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Actions

- (void)cancelButtonTouched:(id)sender
{
    if(self.event.isDraft)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.event resetFromCache];
        [self updateUIForEvent];
        self.shouldUpdateEvent = NO;
        [self editButtonTouched:nil];
    }
}

- (IBAction)editButtonTouched:(id)sender
{
    if(self.isInEditMode)
    {
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
        [self switchToEditingMode];
    }
    self.isInEditMode = !self.isInEditMode;
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:self.isInEditMode];
    }];
}

- (void)switchFromEditingMode
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:NO];
    if([self.descriptionLabel.text isEqualToString:NSLocalizedString(@"ViewController.TextDescriptionContent.TapToAdd", nil)])
    {
        self.descriptionLabel.text = @"";
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
        [self updateEvent];
    }
    self.editButton.title = @"Edit";
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.tableView
                          duration:0.1f
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^(void) {
                            [self.tableView reloadData];
                        } completion:NULL];
        
    });
    [UIView animateWithDuration:2.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tagsLabel.alpha = 1.0f;
        self.tokenContainer.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)switchToEditingMode
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Cancel"
                                   style: UIBarButtonItemStyleBordered
                                   target:self action: @selector(cancelButtonTouched:)];
    
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setHidesBackButton:YES];
    
    if([self.descriptionLabel.text length] == 0)
    {
        self.descriptionLabel.text = NSLocalizedString(@"ViewController.TextDescriptionContent.TapToAdd", nil);
    }
    
    self.editButton.title = @"Done";
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.tableView
                          duration:10.2f
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^(void) {
                               [self.tableView reloadData];
                        } completion:NULL];
   
    });
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tagsLabel.alpha = 0.0f;
        self.tokenContainer.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return self.isInEditMode;
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
        [self updateUIForEvent];
    };
    textEditorVC.text = self.event.eventDescription ? self.event.eventDescription : @"";
}



- (void)setupNoteContentEditorViewController:(TextEditorViewController*)textEditorVC
{
    textEditorVC.textDidChangeCallBack = ^(NSString* text, TextEditorViewController* textEdit) {
        if (self.event.eventContent && [text isEqualToString:self.event.eventContent]) return;
        self.event.eventContent = text;
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    };
    textEditorVC.text = self.event.eventContent ? self.event.eventContent : @"";
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
        [self updateUIForEvent];
    }];
}

- (void)setupImagePreviewViewController:(ImagePreviewViewController*)imagePreviewVC
{
    [self.event firstAttachmentAsImage:^(UIImage *image) {
        imagePreviewVC.image = image;
    } errorHandler:nil];
    
    imagePreviewVC.descText = self.event.eventDescription;
}

- (void)setupAddNumericalValueViewController:(AddNumericalValueViewController*)addNumericalValueVC
{
    if(self.event.type)
    {
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            addNumericalValueVC.value = [self.event.eventContent description];
            addNumericalValueVC.valueClass = [components objectAtIndex:0];
            addNumericalValueVC.valueType = [components objectAtIndex:1];
        }
    }
    [addNumericalValueVC setValueDidChangeBlock:^(NSString* valueClass, NSString *valueType, NSString* value, AddNumericalValueViewController *addNumericalVC) {
        self.event.eventContent = value;
        self.event.type = [NSString stringWithFormat:@"%@/%@",valueClass,valueType];
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    }];
}

- (void)setupStreamPickerViewController:(StreamPickerViewController*)streamPickerVC
{
    streamPickerVC.streamId = self.event.streamId;
    streamPickerVC.delegate = self;
    self.streamPickerVC = streamPickerVC;
    CGRect frame = self.view.bounds;
    frame.origin.y = frame.size.height;
    frame.size.height = frame.size.height - 100;
    self.streamPickerVC.view.frame = frame;
    [self.view addSubview:streamPickerVC.view];

    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect newFrame = self.streamPickerVC.view.frame;
        newFrame.origin.y = 100 + self.tableView.contentOffset.y;
        self.streamPickerVC.view.frame = newFrame;
    } completion:^(BOOL finished) {
        self.tableView.scrollEnabled = NO;
    }];
}

#pragma mark - StreamPickerDelegate methods

- (void)streamPickerDidSelectStream:(PYStream *)stream
{
    self.event.streamId = stream.streamId;
    self.shouldUpdateEvent = YES;
}

- (void)closeStreamPicker
{
    [self updateUIForEvent];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect newFrame = self.streamPickerVC.view.frame;
        newFrame.origin.y = self.view.bounds.size.height;
        self.streamPickerVC.view.frame = newFrame;
    } completion:^(BOOL finished) {
        [self.streamPickerVC.view removeFromSuperview];
        self.streamPickerVC = nil;
        self.tableView.scrollEnabled = YES;
    }];
}

#pragma mark - Utils

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withEvent:(PYEvent*)event
{
    DetailCellType cellType = indexPath.row;
    switch (cellType) {
        case DetailCellTypeValue:
            if(self.eventDataType == EventDataTypeValueMeasure)
            {
                return kValueCellHeight;
            }
            return 0;
            
        case DetailCellTypeImage:
            if(self.eventDataType == EventDataTypeImage)
            {
                return 426;
                UIImage* image = self.picture_ImageView.image;
                CGFloat h = 0;
                if (image.size.height > image.size.width) {
                    h =  (image.size.height / image.size.width) * 320;
                }
                if (h > kImageCellHeight) return h;
       
                return kImageCellHeight;
            }
            return 0;
            
        case DetailCellTypeNote:
            if(self.eventDataType == EventDataTypeNote)
            {
                return kValueCellHeight;
            }
            return 0;
            
        case DetailCellTypeTime:
            return kLineCellHeight;
            
        case DetailCellTypeDescription:
            if(self.isInEditMode) {
                return kLineCellHeight;
            }
            if ([self.descriptionLabel.text length] > 0)
            {
                CGSize textSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(300, FLT_MAX)];
                CGFloat height = textSize.height + 20;
                height = fmaxf(height, 54);
                self.descriptionLabelConstraint1.constant = fmaxf(height - 10,0);
                self.descriptionLabelConstraint2.constant = fmaxf(height - 10,0);
                self.descriptionLabelConstraint3.constant = fmaxf(height - 20,0);
                return height;
            }
            return 0;
            
        case DetailCellTypeTags:
            if (self.isInEditMode || (self.event.tags.count > 0)) {
                CGFloat tagHeight = self.tokenField.frame.size.height + 18;
                self.tagConstraint1.constant = tagHeight - 10;
                self.tagConstraint2.constant = tagHeight - 10;
                self.tagConstraint3.constant = tagHeight - 14;
                self.tagConstraint4.constant = tagHeight - 33;
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
                return tagHeight;
            }
            return 0;
            
        case DetailCellTypeStreams:
            return kLineCellHeight;
            
        default:
            break;
    }
    
    return kLineCellHeight;
}

- (BOOL) shouldCreateEvent
{
    return (self.event.eventId == nil);
}

- (void)saveEvent
{
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil withCompletionBlock:^(PYConnection *connection)
     {
         [connection createEvent:self.event requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId)
          {
              BOOL shouldTakePictureFlag = NO;
              if(self.eventDataType == EventDataTypeImage)
              {
                  shouldTakePictureFlag = self.imagePickerType == UIImagePickerControllerSourceTypeCamera;
              }
              [[DataService sharedInstance] saveEventAsShortcut:self.event andShouldTakePictureFlag:shouldTakePictureFlag];
              [self.navigationController dismissViewControllerAnimated:YES completion:^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
              }];
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
    [self showLoadingOverlay];
    
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil withCompletionBlock:^(PYConnection *connection)
     {
         [connection trashOrDeleteEvent:self.event withRequestType:PYRequestTypeAsync successHandler:^{
             [self.navigationController popViewControllerAnimated:YES];
             double delayInSeconds = 0.3;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
             });
         } errorHandler:^(NSError *error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
             [alert show];
             [self hideLoadingOverlay];
         }];
         
     }];
}

- (void)updateEvent
{
    [self showLoadingOverlay];
    [NotesAppController sharedConnectionWithID:nil
                   noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         [connection updateEvent:self.event successHandler:^(NSString *stoppedId)
          {
              [self.navigationController popViewControllerAnimated:YES];
              double delayInSeconds = 0.3;
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                  [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
              });
          } errorHandler:^(NSError *error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
              [self hideLoadingOverlay];
          }];
     }];
}

- (void)shareEvent
{
    NSLog(@"SHARE EVENT");
}

#pragma mark - DeleteEvent

- (IBAction)deleteButtonTouched:(id)sender {
    [self deleteEvent];
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
    [self updateTagsLabel];
    self.shouldUpdateEvent = YES;
}

#pragma mark - JSTOkenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    [self updateTagsLabel];
    return NO;
}

- (void)tokenFieldWillBeginEditing:(JSTokenField *)tokenField
{
    
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField
{
    
}

- (void)initTags
{
    self.tokenField.delegate = self;
    self.tagDoneButtonConstraint.constant = 0;
    [self.view layoutIfNeeded];
    for(NSString *tag in self.event.tags)
    {
        [self.tokenField addTokenWithTitle:tag representedObject:tag];
    }
    [self updateTagsLabel];
}

- (void)updateTagsLabel
{
    if([self.event.tags count] == 0)
    {
        self.tagsLabel.text = NSLocalizedString(@"ViewController.Tags.TapToAdd", nil);
        self.tokenField.textField.placeholder = NSLocalizedString(@"ViewController.Tags.TapToAdd", nil);
    }
    else
    {
        self.tagsLabel.text = [self.event.tags componentsJoinedByString:@", "];
        self.tokenField.textField.placeholder = @"";
    }
    [self.tokenField updateTokensInTextField:self.tokenField.textField];
}

- (void)tokenContainerDidChangeFrameNotification:(NSNotification*)note
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:DetailCellTypeTags inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:DetailCellTypeTags inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.tagDoneButtonConstraint.constant = 68;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSInteger rowToSelect = 0;
    if(self.eventDataType == EventDataTypeImage)
    {
        rowToSelect = DetailCellTypeImage;
    }
    else if(self.eventDataType == EventDataTypeNote)
    {
        rowToSelect = DetailCellTypeDescription;
    }
    else
    {
        rowToSelect = DetailCellTypeValue;
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.tagDoneButtonConstraint.constant = 0;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
