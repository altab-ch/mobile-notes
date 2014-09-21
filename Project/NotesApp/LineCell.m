//
//  LineCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 15.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "LineCell.h"
#import "JBLineChartView.h"
#import "JBBarChartView.h"
#import "StreamAccessory.h"
#import "PYStream+Helper.h"
#import "NumberAggregateEvents.h"
#import "ChartView.h"

@interface LineCell () <ChartViewDelegate>
@property(nonatomic) GraphStyle graphStyle;
@property (nonatomic, strong) UIColor *lineColor, *fillColor;
@property (nonatomic, weak) IBOutlet UIView *chartView, *backView2;
@property (nonatomic, weak) IBOutlet UILabel *lbValue, *lbUnit, *lbDescription, *lbDate;
@end

@implementation LineCell

- (void)updateWithAggregateEvent:(NumberAggregateEvents*)aggEvent
{
    self.aggEvents = aggEvent;
    [super updateWithEvent:[aggEvent.events objectAtIndex:0]];
    [self displayEvent:[aggEvent.events count]-1];

    [self.backView2.layer setBorderWidth:1];
    [self.backView2.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    ChartView *chart = [[ChartView alloc] initWithFrame:self.chartView.bounds];
    [chart setChartDelegate:self];
    [chart updateWithAggregateEvents:aggEvent];
    [chart setUserInteractionEnabled:NO];
    [self.chartView addSubview:chart];
    
    StreamAccessory *st = [[StreamAccessory alloc] initText:[[aggEvent.events objectAtIndex:0] eventBreadcrumbs] color:[[[aggEvent.events objectAtIndex:0] stream] getColor]];
    [self addSubview:st];
    
}

-(void) displayLastEvent
{
    [self displayEvent:[self.aggEvents.events count]-1];
}

-(void) displayEvent:(NSInteger)index
{
    PYEvent *refEvent = [self.aggEvents.events objectAtIndex:index];
    [self.lbValue setText:refEvent.eventContentAsString];
    [self.lbDescription setText:[refEvent.pyType localizedName]];
    [self.lbUnit setText:[refEvent.pyType symbol]];
    [self.lbDate setText:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:refEvent.eventDate]];
}

#pragma mark ChartView Delegate

-(void) didSelectEvents:(NSArray*)events withType:(NSString*)type value:(NSString*)value date:(NSString*)date
{
    if ([events count] > 0) {
        PYEvent *refEvent = (PYEvent*)[events objectAtIndex:0];
        [self.lbValue setText:value];
        [self.lbDescription setText:[refEvent.pyType localizedName]];
        [self.lbUnit setText:[refEvent.pyType symbol]];
        [self.lbDate setText:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:refEvent.eventDate]];
    }
    
}

-(void) updateInfo:(NSString*)type value:(NSString*)value unit:(NSString*)unit description:(NSString*)description
{
    
}

@end
