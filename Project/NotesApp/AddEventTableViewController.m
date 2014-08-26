//
//  AddEventTableViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 02.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AddEventTableViewController.h"
#import "LRUManager.h"
#import "BrowseEventsCell.h"
#import "PhotoNoteViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+Utils.h"
#import "PYEvent+Helper.h"
#import "UnitPickerViewController.h"
#import "DetailViewController.h"

#define kAddToUnitSegue_ID @"kAddToUnitSegue_ID"
#define kAddToDetailSegue_ID @"kAddToDetailSegue_ID"

@interface AddEventTableViewController () <MCSwipeTableViewCellDelegate, UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UnitPickerDelegate>

@property (nonatomic, strong) NSArray *lruEntries;
@property (nonatomic, strong) UserHistoryEntry* tempEntry;

-(IBAction)createEvent:(UIButton*)sender;

@end

@implementation AddEventTableViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.lruEntries = [[LRUManager sharedInstance] lruEntries];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"AddEvent.Title", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    
    return [self.lruEntries count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"kEvent1"];
        [(UILabel*)[cell viewWithTag:5] setText:NSLocalizedString(@"AddEvent.Note", nil)];
        [(UILabel*)[cell viewWithTag:6] setText:NSLocalizedString(@"AddEvent.Numeric", nil)];
        [(UILabel*)[cell viewWithTag:7] setText:NSLocalizedString(@"AddEvent.Picture", nil)];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"kShortcut"];
        UserHistoryEntry *entry = [self.lruEntries objectAtIndex:indexPath.row];
        [(BrowseEventsCell*)cell setupWithUserHistroyEntry:entry];
        [self configureCell:(BrowseEventsCell*)cell];
    }
    
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"kSection"];
    UILabel *targetedLabel = (UILabel *)[headerCell viewWithTag:5];
    [targetedLabel setText:NSLocalizedString(@"LastUsedShortcut.Title", nil)];
    return headerCell.contentView;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 110;
    
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    
    return 20;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UserHistoryEntry *uhe = [self.lruEntries objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        if ([uhe dataType] == EventDataTypeImage) {
            self.tempEntry = uhe;
            [self showPicturePicker];
        }
        if ([uhe dataType] == EventDataTypeNote || [uhe dataType] == EventDataTypeValueMeasure) {
            [self showEventDetailsForEvent:[uhe reconstructEvent]];
        }
    }
}

#pragma mark - IBAction, segue

-(IBAction)createEvent:(UIButton*)sender
{
    switch (sender.tag) {
        case 1:
        {
            PYEvent *event = [self getNewEvent];
            event.type = @"note/txt";
            [self showEventDetailsForEvent:event];
        }
            break;
        case 2:
        {
            PYEvent *event = [self getNewEvent];
            event.type = @"number";
            [self performSegueWithIdentifier:kAddToUnitSegue_ID sender:event];
        }
            break;
        case 3:
        {
            [self showPicturePicker];
        }
            break;
        default:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This option is not yet implemented" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PYEvent*)sender
{
    if ([[segue identifier] isEqualToString:kAddToDetailSegue_ID]) {
        DetailViewController *detail = [segue destinationViewController];
        [detail setEvent:sender];
    }
    
    if ([[segue identifier] isEqualToString:kAddToUnitSegue_ID]) {
        UnitPickerViewController *unit = [segue destinationViewController];
        [unit setDelegate:self];
        [unit setEvent:sender];
    }
}

-(void) showPicturePicker
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Alert.Message.PhotoSource", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil),NSLocalizedString(@"Library", nil), nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UnitPickerDelegate

-(void)unitPickerController:(UIViewController*)picker didFinishPickingUnit:(PYEvent*)event
{
    [self.navigationController popViewControllerAnimated:NO];
    [self showEventDetailsForEvent:event];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    if(buttonIndex == actionSheet.cancelButtonIndex)
    {
        self.tempEntry = nil;
        return;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"AddEvent.CameraUnavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    UIImagePickerController *photoVC = [[UIImagePickerController alloc] init];
    photoVC.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    [photoVC setDelegate:self];
    [self presentViewController:photoVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    //selectedImage = [self scaledImageForImage:selectedImage];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *aLib = [[ALAssetsLibrary alloc] init];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [aLib writeImageToSavedPhotosAlbum:[selectedImage CGImage] orientation:(ALAssetOrientation)[selectedImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Error.SavingImageError", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        }];
    }
    
    [aLib assetForURL:imageURL resultBlock:^(ALAsset *asset) {
        NSDictionary *metadata = asset.defaultRepresentation.metadata;
        NSDate *date = nil;
        if(metadata)
        {
            NSString *timeString = [[metadata objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"];
            if (!timeString) timeString = [[metadata objectForKey:@"{Exif}"] objectForKey:@"DateTimeDigitized"];
            
            if(timeString)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                date = [dateFormatter dateFromString:timeString];
                
            }
        }
        
        /*[picker dismissViewControllerAnimated:YES completion:^{
            NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.7);
            if(!imageData) return;
            
            NSString *imgName = [NSString randomStringWithLength:10];
            PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:imgName fileName:[NSString stringWithFormat:@"%@.jpeg",imgName]];
            PYEvent *newEvent;
            if (self.tempEntry) {
                newEvent = [self.tempEntry reconstructEvent];
                self.tempEntry = nil;
            }else{
                newEvent = [[PYEvent alloc] init];
                newEvent.type = @"picture/attached";
            }
            
            [newEvent setAttachments:[NSMutableArray arrayWithObject:att]];
            [newEvent setEventDate:date];
            [self showEventDetailsForEvent:newEvent];
        }];*/
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.7);
        if(!imageData) return;
        
        NSString *imgName = [NSString randomStringWithLength:10];
        PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:imgName fileName:[NSString stringWithFormat:@"%@.jpeg",imgName]];
        PYEvent *newEvent;
        if (self.tempEntry) {
            newEvent = [self.tempEntry reconstructEvent];
            [newEvent setConnection:[NotesAppController sharedInstance].connection];
            self.tempEntry = nil;
        }else{
            newEvent = [self getNewEvent];
            newEvent.type = @"picture/attached";
        }
        
        [newEvent setAttachments:[NSMutableArray arrayWithObject:att]];
        [newEvent setEventDate:date];
        [self showEventDetailsForEvent:newEvent];
        
    } failureBlock:^(NSError *error) {
        [picker dismissViewControllerAnimated:YES completion:^{self.tempEntry = nil;}];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.tempEntry = nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - utils

- (void)configureCell:(MCSwipeTableViewCell *)cell{
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    [cell setDefaultColor:[UIColor lightGrayColor]];
    [cell setDelegate:self];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSIndexPath *indexPathToDelete = [self.tableView indexPathForCell:cell];
        [[LRUManager sharedInstance] removeObjectFromLruEntriesAtIndex:indexPathToDelete.row];
        self.lruEntries = [LRUManager sharedInstance].lruEntries;
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void)showEventDetailsForEvent:(PYEvent*)event
{
    if (event == nil) return;
    [event setConnection:[NotesAppController sharedInstance].connection];
    [self performSegueWithIdentifier:kAddToDetailSegue_ID sender:event];
}

-(PYEvent*) getNewEvent
{
    PYEvent *event = [[PYEvent alloc] init];
    event.connection = [NotesAppController sharedInstance].connection;
    return event;
}

@end