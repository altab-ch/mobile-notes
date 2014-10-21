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

@end

@implementation AggregateEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 3;
    if (self.events) return [self.events count];
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = 0;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                result = 48;
                break;
                
            case 1:
                result = 200;
                break;
                
            case 2:
                result = 52;
                break;
                
            default:
                break;
        }
    }else
        result = 120;
    
    return result;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section ? NSLocalizedString(@"AggEvent.header.events", nil) : NSLocalizedString(@"AggEvent.header.schart", nil);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cel = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cel = [self.tableView dequeueReusableCellWithIdentifier:@"stream_id"];
                UIView *pastille = (UIView *)[cel viewWithTag:13];
                UILabel *lbStream = (UILabel *)[cel viewWithTag:14];
                UILabel *lbUnit = (UILabel *)[cel viewWithTag:15];
                
                [pastille setBackgroundColor:self.aggEvents.streamColor];
                [lbStream setText:self.aggEvents.breadCrumbs];
                [lbUnit setText:[self.aggEvents.pyType localizedName]];
            }
                break;
                
            case 1:
            {
                cel = [self.tableView dequeueReusableCellWithIdentifier:@"schart_id"];
                SChartView *sChartView = (SChartView*)[cel viewWithTag:10];
                [sChartView setChartDelegate:self];
                [sChartView updateWithAggregateEvents:self.aggEvents withContext:ChartViewContextDetail];
            }
                break;
                
            case 2:
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
        ValueCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"value_id"];
        PYEvent *event = [self.events objectAtIndex:indexPath.row];
        [cell updateWithEvent:event];
        return cell;
    }
    
    return cel;
}

/*-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)[self performSegueWithIdentifier:@"DetailViewSegue_ID" sender:[self.events objectAtIndex:indexPath.row]];
}*/

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(ValueCell*)sender
{
    DetailViewController *detail = [segue destinationViewController];
    [detail setEvent:sender.event];
}

#pragma mark ChartView Delegate

-(void) didSelectEvents:(NSArray*)events withType:(NSString*)type value:(NSString*)value date:(NSString*)date
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
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
