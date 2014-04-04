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

@interface StreamPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL visible;
@property (nonatomic, strong) IBOutlet UIButton *listBackButton;
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) NSArray *rootStreams;
@property (nonatomic, strong) PYStream *stream;

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
    [self initStreams];
    
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

- (void)initStreams
{
    [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id object, NSError *error) {
        if(error)
        {
            NSLog(@"ERROR!!!!!!!");
        }
        else
        {
            self.streams = object;
            NSString *streamID = nil;
            if((self.entry && self.entry.streamId))
            {
                streamID = self.entry.streamId;
            }
            else
            {
                streamID = self.streamId;
            }
            for(PYStream *stream in self.streams)
            {
                if([stream.streamId isEqualToString:streamID])
                {
                    self.stream = stream;
                    break;
                }
            }
            self.rootStreams = [self.streams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parentId = nil"]];
        }
        [self updateUIElements];
        [self.tableView reloadData];
    }];
}

- (void)updateUIElements
{
    NSString *selectedText = [self.stream breadcrumbs];
    if(!selectedText && [selectedText length] < 1)
    {
        selectedText = NSLocalizedString(@"ViewController.Streams.SelectStream", nil);
    }
    self.streamLabel.text = selectedText;
    
    self.listBackButton.hidden = (self.stream == nil);
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
        stream.parentId = self.stream.streamId;
        
        [NotesAppController sharedConnectionWithID:nil
                 noConnectionCompletionBlock:nil
                         withCompletionBlock:^(PYConnection *connection)
         {
             [connection createStream:stream withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdStreamId) {
                 
                 // TODO replace this with Stream update notifications
                 [[DataService sharedInstance] invalidateStreamListCache];
                 [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id object, NSError *error) {
                     self.streams = object;
                     self.rootStreams = [self.streams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parentId = nil"]];
                     for(PYStream *st in self.streams)
                     {
                         if([st.name isEqualToString:stream.name] && ([st.parentId isEqualToString:stream.parentId] || stream.parentId == nil))
                         {
                             self.stream = st;
                             break;
                         }
                     }
                     [self.tableView reloadData];
                     [self updateUIElements];
                     [self hideLoadingOverlay];
                     [self.delegate streamPickerDidSelectStream:self.stream];
                 }];
                 
                 
             } errorHandler:^(NSError *error) {
                 [self hideLoadingOverlay];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }];
         }];
        
    }
}

- (NSArray*)parentStreamList
{
    if(!self.stream)
    {
        return self.rootStreams;
    }
    else
    {
        return self.stream.children;
    }
}

@end
