//
//  MenuTableViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 02.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "MenuTableViewController.h"

#define DATE_SECTION 0
#define DATE_LABEL_ROW 0
#define DATE_PICKER_ROW 1

static NSString *kPickerCellID = @"picker_cell";
static NSString *kDateCellID = @"date_cell";
static NSString *kStreamCellID = @"stream_cell";
static NSString *kSectionCellID = @"section_cell";
static int kSectionTag = 13;
static int kStreamTag = 11;
static int kDateTag = 12;
static int kPickerTag = 10;

@interface MenuTableViewController ()

@property (nonatomic) BOOL datePickerIsHidden;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic) float pickerCellRowHeight;
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) NSMutableArray *streamIDs;

- (IBAction)dateChanged:(UIDatePicker *)sender;

@end

@implementation MenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createDateFormatter];
    [self setDatePickerIsHidden:true];
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier: kPickerCellID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
    [self initStreams];
#warning todo
    [self setDate:[NSDate dateWithTimeIntervalSinceNow:0]];
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
    NSInteger numberOfRows = 0;
    
    if (section==DATE_SECTION) {
        if ([self datePickerIsHidden])
            numberOfRows=1;
        else
            numberOfRows=2;
    }
    else if (self.streams) numberOfRows = [self.streams count];
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = self.tableView.rowHeight;
    
    if ((indexPath.row==DATE_PICKER_ROW) && (indexPath.section==DATE_SECTION))
        rowHeight = self.pickerCellRowHeight;
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section==DATE_SECTION) {
        switch (indexPath.row) {
            case DATE_LABEL_ROW:
                cell = [self createDateCell];
                break;
                
            case DATE_PICKER_ROW:
                cell = [self createPickerCell];
                break;
                
            default:
                NSLog(@"cell not defined");
                break;
        }
    }else{
        cell = [self createStreamCell:[[self.streams objectAtIndex:indexPath.row] name]];
    }
    
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:kSectionCellID];
    UILabel *targetedLabel = (UILabel *)[headerCell viewWithTag:kSectionTag];
    if (section==DATE_SECTION) {
        targetedLabel.text = @"Date";
    }else
        targetedLabel.text = @"Streams";
    
    
    return headerCell.contentView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    
    if (indexPath.section==DATE_SECTION) {
        if (indexPath.section==DATE_SECTION) {
            if (indexPath.row == DATE_LABEL_ROW) {
                if ([self datePickerIsHidden])
                    [self showPicker];
                else
                    [self hidePicker];
            }
        }
    }else{
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView endUpdates];
}

#pragma mark - IB method

- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:DATE_LABEL_ROW inSection:DATE_SECTION]];
    UILabel *targetedLabel = (UILabel *)[cell viewWithTag:kDateTag];
    targetedLabel.text = [self.dateFormatter stringFromDate:sender.date];
    [self setDate:sender.date];
}

#pragma mark - misc

- (void)initStreams
{
    
    PYConnection* connection = [[NotesAppController sharedInstance] connection];
    if (connection == nil) {
        NSLog(@"<ERROR> StreamPickerViewController.initStreams connection is nil");
        return;
    }
    
    self.streams = connection.fetchedStreamsRoots;
}

- (void)createDateFormatter {
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)resetMenu
{
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (![self datePickerIsHidden])
        [self hidePickerReset];
}

- (void)hidePickerReset {
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DATE_PICKER_ROW inSection:DATE_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self setDatePickerIsHidden:YES];
    [self.tableView endUpdates];
}

- (void)hidePicker {
    
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:DATE_PICKER_ROW inSection:DATE_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self setDatePickerIsHidden:YES];
}

- (void)showPicker{
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:DATE_PICKER_ROW inSection:DATE_SECTION]];
    [self setDatePickerIsHidden:NO];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCell *)createDateCell {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
    UILabel *targetedLabel = (UILabel *)[cell viewWithTag:kDateTag];
    
    targetedLabel.text = [self.dateFormatter stringFromDate:self.date];
    
    return cell;
    
}

- (UITableViewCell *)createPickerCell{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPickerCellID];
    
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:kPickerTag];
    
    [targetedDatePicker setDate:self.date animated:NO];
    
    return cell;
}

- (UITableViewCell *)createStreamCell:(NSString*)stream_name{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kStreamCellID];
    UILabel *targetedLabel = (UILabel *)[cell viewWithTag:kStreamTag];
    targetedLabel.text = stream_name;
    
    return cell;
}

- (NSArray*) getStreamIDs
{
    return nil;
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
