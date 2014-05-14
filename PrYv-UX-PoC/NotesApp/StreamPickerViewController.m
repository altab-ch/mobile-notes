//
//  StreamPickerViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//
#import "StreamPickerViewController.h"
#import "PYStream+Helper.h"
#import "DataService.h"
#import "UserHistoryEntry.h"
#import "StreamCell.h"
#import "UIAlertView+PrYv.h"
#import "NotesAppController.h"
#import "PYStream+Utils.h"

@interface StreamPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL visible;
@property (nonatomic, strong) IBOutlet UIButton *listBackButton;

@end

@implementation StreamPickerViewController

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
    
    self.visible = NO;
	
    UITapGestureRecognizer *streamTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(streamsLabelTouched:)];
    self.streamLabel.userInteractionEnabled = YES;
    [self.streamLabel addGestureRecognizer:streamTapGR];
    [self.cancelButton setTitle: NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self updateUIElements];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)streamsLabelTouched:(id)sender
{
    self.visible = !self.visible;
    [self.delegate closeStreamPicker];
}


- (void)updateUIElements
{
    NSString *selectedText = [self.stream breadcrumbs];
    if(!selectedText || [selectedText length] < 1)
    {
        selectedText = NSLocalizedString(@"ViewController.Streams.SelectStream", nil);
    }
    self.streamLabel.text = selectedText;
    
    self.listBackButton.hidden = (self.stream == nil);
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)backButtonTouched:(id)sender
{
    self.stream = [self.stream parent];
    [self.tableView reloadData];
    [self updateUIElements];
    [self.delegate streamPickerDidSelectStream:self.stream];
}

- (IBAction)cancelButtonTouched:(id)sender
{
    self.visible = !self.visible;
    [self.delegate cancelStreamPicker];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self parentStreamList] count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StreamCell_ID";
    StreamCell *cell = (StreamCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.index = indexPath.row;
    if(indexPath.row == [[self parentStreamList] count])
    {
        [self setupAddStreamCell:cell];
    }
    else
    {
        [self setupRegularCell:cell];
    }
    
    return cell;
}

- (void)setupAddStreamCell:(StreamCell*)cell
{
    cell.accessoryImageView.image = [UIImage imageNamed:@"circle-add"];
    cell.streamName.text = NSLocalizedString(@"ViewController.Streams.AddNewStream", nil);
    [cell setStreamCellTappedHandler:^(StreamCell *tappedCell, NSInteger index) {
        [self showAddNewStreamDialog];
    }];
    [cell setStreamAccessoryTappedHandler:^(StreamCell *tappedCell, NSInteger index) {
        [self showAddNewStreamDialog];
    }];
}



- (void)showAddNewStreamDialog
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ViewController.Streams.StreamName", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Add", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            NSString *streamName = [[alertView textFieldAtIndex:0] text];
            [self createNewStreamWithName:streamName];
        }
    }];
}

- (void)updateStreamCellDetails:(StreamCell *)cell withStream:(PYStream *)stream
{
    cell.accessoryImageView.image = [UIImage imageNamed:@"circle-chevron-right"];
    cell.streamName.text = stream.name;
    BOOL isSelected = [stream.streamId isEqualToString:self.stream.streamId];
    [cell setSelected:isSelected animated:NO];
}

- (void)setupRegularCell:(StreamCell*)cell
{
    PYStream *stream = [[self parentStreamList] objectAtIndex:cell.index];
    [self updateStreamCellDetails:cell withStream:stream];
    [cell setStreamCellTappedHandler:^(StreamCell *tappedCell, NSInteger index) {
        PYStream *stream = [[self parentStreamList] objectAtIndex:index];
        self.stream = stream;
        [self.tableView reloadData];
        [self updateUIElements];
        [self.delegate streamPickerDidSelectStream:self.stream];
        [self streamsLabelTouched:nil];
    }];
    [cell setStreamAccessoryTappedHandler:^(StreamCell *tappedCell, NSInteger index) {
        PYStream *stream = [[self parentStreamList] objectAtIndex:index];
        self.stream = stream;
        [self.tableView reloadData];
        [self updateUIElements];
    }];
}

#pragma mark - UITableViewDelegate methods

#pragma mark - Utils

- (void)createNewStreamWithName:(NSString *)streamName
{
    if([streamName length] > 0)
    {
        [self showLoadingOverlay];
        PYStream *stream = [[PYStream alloc] init];
        stream.name = streamName;
        if (self.stream) {
            stream.parentId = self.stream.streamId;
        }
            
        [NotesAppController sharedConnectionWithID:nil
                       noConnectionCompletionBlock:nil
                               withCompletionBlock:^(PYConnection *connection)
         {
             [connection streamCreate:stream successHandler:^(NSString *createdStreamId) {
                
                 
                 [self updateUIElements];
                 [self hideLoadingOverlay];
                 [self.delegate streamPickerDidSelectStream:stream];
                 
             } errorHandler:^(NSError *error) {
                 [self hideLoadingOverlay];
                 NSString* message = [error localizedDescription];
                 if (error.userInfo && [error.userInfo objectForKey:@"message"]) {
                     message = [error.userInfo objectForKey:@"message"];
                 }
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ViewController.Streams.ErrorCreatingStream", nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }];
         }];
        
    }
}

- (NSArray*)parentStreamList
{
    if(!self.stream)
    {
        if (! [NotesAppController sharedInstance].connection ||
            ! [NotesAppController sharedInstance].connection.fetchedStreamsRoots) {
            return [[NSArray alloc] init];
        }
        return [NotesAppController sharedInstance].connection.fetchedStreamsRoots;
    }
    else
    {
        return self.stream.children;
    }
}

@end
