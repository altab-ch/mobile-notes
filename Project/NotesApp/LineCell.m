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
#import "SChartView.h"

@interface LineCell () <ChartViewDelegate, SChartViewDelegate>
@property(nonatomic) GraphStyle graphStyle;
@property (nonatomic, strong) UIColor *lineColor, *fillColor;
@property (nonatomic, weak) IBOutlet UIView *chartView;
@property (nonatomic, weak) IBOutlet UILabel *lbValue, *lbUnit, *lbDate, *lbDescription, *lbHistory;
@property (nonatomic, weak) IBOutlet SChartView *schartView;
@end

@implementation LineCell

- (void)updateWithAggregateEvent:(NumberAggregateEvents*)aggEvent
{
    self.aggEvents = aggEvent;
    [super updateWithEvent:[aggEvent.events objectAtIndex:0]];
    [self displayEvent:[aggEvent.events count]-1];

    /*ChartView *chart = [[ChartView alloc] initWithFrame:self.chartView.bounds];
    [chart setChartDelegate:self];
    [chart updateWithAggregateEvents:aggEvent];
    [chart setUserInteractionEnabled:NO];
    [self.chartView addSubview:chart];*/
    
    [self.schartView setChartDelegate:self];
    [self.schartView updateWithAggregateEvents:aggEvent withContext:ChartViewContextBrowser];
        
    for (UIView *vi in self.subviews) {
        if ([vi isKindOfClass:[StreamAccessory class]]) {
            [vi removeFromSuperview];
        }
    }
    
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
    if ([refEvent.eventContent isKindOfClass:[NSNumber class]]) {
        [self.lbValue setText:[[[NotesAppController sharedInstance] numf] stringFromNumber:refEvent.eventContent]];
    }else
        [self.lbValue setText:refEvent.eventContentAsString];
    
    if (!refEvent.pyType.symbol)
    {
        [self.lbUnit setText:[refEvent.pyType localizedName]];
        [self.lbDescription setText:@""];
    }
    
    else{
        [self.lbUnit setText:[refEvent.pyType symbol]];
        [self.lbDescription setText:[refEvent.pyType localizedName]];
    }
    
    NSString *type = [self aggregateEvents].transform ? [self aggregateEvents].typeLocalized : NSLocalizedString(@"None", nil);
    
    NSString *history = [NSString stringWithFormat:@"1 %@, %@", [(NumberAggregateEvents*)self.aggEvents historyLocalized], type];
    [self.lbHistory setText:history];
    [self.lbDate setText:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:refEvent.eventDate]];
}

-(NumberAggregateEvents*)aggregateEvents
{
    return (NumberAggregateEvents*)self.aggEvents;
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
