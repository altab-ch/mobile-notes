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

@interface AddEventTableViewController () <MCSwipeTableViewCellDelegate, UIActionSheetDelegate>

@property (nonatomic,retain) NSArray *lruEntries;

-(IBAction)createEvent:(UIButton*)sender;

@end

@implementation AddEventTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.lruEntries = [[LRUManager sharedInstance] lruEntries];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - IB

-(IBAction)createEvent:(UIButton*)sender
{
    switch (sender.tag) {
        case 1:
        {
            PYEvent *event = [[PYEvent alloc] init];
            event.type = @"note/txt";
            [self showEventDetailsForEvent:event andUserHistoryEntry:nil];
        }
            break;
        case 2:
        {
            PYEvent *event = [[PYEvent alloc] init];
            [self showEventDetailsForEvent:event andUserHistoryEntry:nil];
        }
            break;
        case 3:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Alert.Message.PhotoSource", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil),NSLocalizedString(@"Library", nil), nil];
            [actionSheet showInView:self.view];
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

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"CameraUnavailable", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    UIImagePickerControllerSourceType sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    /*if(self.tempEntry)
    {
        UserHistoryEntry *entry = self.tempEntry;
        self.isSourceTypePicked = @(sourceType);
        [self showEventDetailsWithUserHistoryEntry:entry];
        self.tempEntry = nil;
        return;
    }*/
    PhotoNoteViewController *photoVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"PhotoNoteViewController_ID"];
    photoVC.sourceType = sourceType;
    //photoVC.browseVC = self;
    [self.navigationController pushViewController:photoVC animated:YES];
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

- (void)showEventDetailsForEvent:(PYEvent*)event andUserHistoryEntry:(UserHistoryEntry*)entry
{
    /*if (event == nil) {
        [NSException raise:@"Event is nil" format:nil];
    }
    
    EventDetailsViewController *eventDetailVC = (EventDetailsViewController*)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController_ID"];
    eventDetailVC.event = event;
    
    EventDataType eventType = [eventDetailVC.event eventDataType];
    
    
    if(eventType == EventDataTypeImage)
    {
        eventDetailVC.imagePickerType = self.imagePickerType;
    }
    
    if(event.isDraft)
    {
#warning recoder : navigation presentviewcontroller detailViewController
        //[eventDetailVC view];
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
    }*/
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
