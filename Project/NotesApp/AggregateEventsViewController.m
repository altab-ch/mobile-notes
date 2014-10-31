//
//  AggregateEventsViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 21.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateEventsViewController.h"
#import "DetailViewController.h"
#import "SChartView.h"
#import "ValueCell.h"

@interface AggregateEventsViewController () <SChartViewDelegate>

@property (nonatomic, weak) NSArray *events;
@property (nonatomic) BOOL isEdit, isGraphStyle, isTransform;
@property (nonatomic, strong) NSArray *graphStyle, *transform;
@end

@implementation AggregateEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEdit = NO;
    self.isGraphStyle = NO;
    self.isTransform = NO;
    self.transform = @[NSLocalizedString(@"None", nil), NSLocalizedString(@"AverageBy", nil), NSLocalizedString(@"SumBy", nil)];
    self.graphStyle = @[NSLocalizedString(@"Bar", nil), NSLocalizedString(@"Line", nil)];
}

#pragma mark TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 2;
    if (self.isEdit)
    {
        if (self.isGraphStyle) return 2;
        else if (self.isTransform) return 3;
        else return 2;
    }

    if (self.events) return [self.events count];
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = 0;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                result = 200;
                break;
                
            case 1:
                result = 52;
                break;
                
            default:
                break;
        }
    }else{
        if (self.isEdit) result = 44;
        else result = 120;
    }
    return result;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return nil;
    
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"stream_id"];
    UIView *pastille = (UIView *)[headerCell viewWithTag:13];
    UILabel *lbStream = (UILabel *)[headerCell viewWithTag:14];
    UILabel *lbUnit = (UILabel *)[headerCell viewWithTag:15];
    
    [pastille setBackgroundColor:self.aggEvents.streamColor];
    [lbStream setText:self.aggEvents.breadCrumbs];
    [lbUnit setText:[self.aggEvents.pyType localizedName]];
    return headerCell.contentView;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.isEdit ? NSLocalizedString(@"AggEvent.header.settings", nil) : NSLocalizedString(@"AggEvent.header.events", nil);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cel = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
                
            case 0:
            {
                cel = [self.tableView dequeueReusableCellWithIdentifier:@"schart_id"];
                SChartView *sChartView = (SChartView*)[cel viewWithTag:10];
                [sChartView setChartDelegate:self];
                [sChartView updateWithAggregateEvents:self.aggEvents withContext:ChartViewContextDetail];
            }
                break;
                
            case 1:
            {
                cel = [self.tableView dequeueReusableCellWithIdentifier:@"valueInfo_id"];
                UILabel *lbType = (UILabel *)[cel viewWithTag:11];
                UILabel *lbValue = (UILabel *)[cel viewWithTag:12];
                [lbType setText:@""];
                [lbValue setText:@""];
            }
                break;
                
            default:
                break;
        }
        
    }
    else if (indexPath.section == 1)
    {
        if (self.isEdit) {
            if (self.isGraphStyle) {
                
                cel = [self.tableView dequeueReusableCellWithIdentifier:@"multiChoice_id"];
                UILabel *lbType = (UILabel *)[cel viewWithTag:10];
                [lbType setText:[self.graphStyle objectAtIndex:indexPath.row]];
                if (self.aggEvents.graphStyle == indexPath.row) [cel setAccessoryType:UITableViewCellAccessoryCheckmark];
                else [cel setAccessoryType:UITableViewCellAccessoryNone];
            }
            else if (self.isTransform)
            {
                cel = [self.tableView dequeueReusableCellWithIdentifier:@"multiChoice_id"];
                UILabel *lbType = (UILabel *)[cel viewWithTag:10];
                [lbType setText:[self.transform objectAtIndex:indexPath.row]];
                if (self.aggEvents.transform == indexPath.row) [cel setAccessoryType:UITableViewCellAccessoryCheckmark];
                else [cel setAccessoryType:UITableViewCellAccessoryNone];
            }
            else
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        cel = [self.tableView dequeueReusableCellWithIdentifier:@"type_id"];
                        UILabel *lbType = (UILabel *)[cel viewWithTag:10];
                        [lbType setText:[self.aggEvents graphStyleLocalized]];
                    }
                        break;
                        
                    case 1:
                    {
                        cel = [self.tableView dequeueReusableCellWithIdentifier:@"transform_id"];
                        UILabel *lbType = (UILabel *)[cel viewWithTag:10];
                        [lbType setText:[self.aggEvents typeLocalized]];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
        }else{
            ValueCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"value_id"];
            PYEvent *event = [self.events objectAtIndex:indexPath.row];
            [cell updateWithEvent:event];
            return cell;
        }
    }
    
    return cel;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && self.isEdit) {
        if (self.isGraphStyle) {
            [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            self.aggEvents.graphStyle = (int)indexPath.row;
            self.isGraphStyle = NO;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else if (self.isTransform)
        {
            [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            self.aggEvents.transform = (int)indexPath.row;
            self.isTransform = NO;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
        }
        else
        {
            if (indexPath.row == 0) {
                self.isGraphStyle = YES;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
            else if(indexPath.row == 1)
            {
                self.isTransform = YES;
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(ValueCell*)sender
{
    DetailViewController *detail = [segue destinationViewController];
    [detail setEvent:sender.event];
}

#pragma mark ChartView Delegate

-(void) didSelectEvents:(NSArray*)events withType:(NSString*)type value:(NSString*)value date:(NSString*)date
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UILabel *lbType = (UILabel *)[cell viewWithTag:11];
    UILabel *lbValue = (UILabel *)[cell viewWithTag:12];
    [lbType setText:[NSString stringWithFormat:NSLocalizedString(@"AggEvent.type", nil), type, date]];
    [lbValue setText:value];
    
    [self.tableView beginUpdates];
    
    if ([self.events count]) {
        NSMutableArray *rows = [NSMutableArray array];
        for (int i=0; i < self.events.count; i++) {
            [rows addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];

    }
    
    self.events = events;
    
    if ([self.events count]) {
        NSMutableArray *rows = [NSMutableArray array];
        for (int i=0; i < self.events.count; i++) {
            [rows addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

-(void) updateInfo:(NSString*)type value:(NSString*)value unit:(NSString*)unit description:(NSString*)description
{
    
}

#pragma mark - utils

-(IBAction)btEditTouched:(id)sender
{
    if (self.isEdit)
    {
        self.isEdit = !self.isEdit;
        self.isGraphStyle = NO;
        self.isTransform = NO;
        UITableViewCell* cel = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        SChartView *sChartView = (SChartView*)[cel viewWithTag:10];
        [sChartView setUserInteractionEnabled:YES];
        
        [self.tableView beginUpdates];
        //[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        self.isEdit = !self.isEdit;
        self.isGraphStyle = NO;
        self.isTransform = NO;

        UITableViewCell* cel = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        SChartView *sChartView = (SChartView*)[cel viewWithTag:10];
        [sChartView setUserInteractionEnabled:NO];
        //[sChartView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
