//
//  AggregateEventsViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 21.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateEventsViewController.h"
#import "ChartView.h"
#import "DetailViewController.h"
#import "SChartView.h"

@interface AggregateEventsViewController () <UITableViewDelegate, UITableViewDataSource, ChartViewDelegate, SChartViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *value, *type, *date, *unitDesc;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet ChartView *chartView;
@property (nonatomic, weak) IBOutlet SChartView *schartView;
@property (nonatomic, weak) NSArray *events;

@end

@implementation AggregateEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.chartView setChartDelegate:self];
    //[self.chartView updateWithAggregateEvents:self.aggEvents];
    
    [self.schartView setChartDelegate:self];
    [self.schartView updateWithAggregateEvents:self.aggEvents];
}

#pragma mark ScrollView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.events) return [self.events count];
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ValueCell_ID"];
    PYEvent *event = [self.events objectAtIndex:indexPath.row];
    [(UILabel*)[cell viewWithTag:10] setText:[event.eventContent description]];
    [(UILabel*)[cell viewWithTag:11] setText:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:event.eventDate]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"DetailViewSegue_ID" sender:[self.events objectAtIndex:indexPath.row]];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(PYEvent*)sender
{
    DetailViewController *detail = [segue destinationViewController];
    [detail setEvent:sender];
}

#pragma mark ChartView Delegate

-(void) didSelectEvents:(NSArray*)events withType:(NSString*)type value:(NSString*)value date:(NSString*)date
{
    [self.value setText:value];
    [self.date setText:date];
    self.events = events;
    [self.tableView reloadData];
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
