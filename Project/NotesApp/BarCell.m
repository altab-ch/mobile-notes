//
//  BarCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 15.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BarCell.h"
#import "BarAggregateEvents.h"
#import "JBBarChartView.h"
#import "StreamAccessory.h"
#import "PYStream+Helper.h"

@interface BarCell () <JBBarChartViewDataSource, JBBarChartViewDelegate>

@property (nonatomic, strong) IBOutlet JBBarChartView *barChartView;
@property (nonatomic, strong) UIColor *color;

@end

@implementation BarCell

- (void)updateWithAggregateEvent:(BarAggregateEvents*)aggEvent
{
    [super updateWithEvent:[aggEvent.events objectAtIndex:0]];
    
    self.aggEvents = aggEvent;
    self.color = [UIColor colorWithRed:189.0/255.0 green:9.0/255.0 blue:38.0/255.0 alpha:0.8];
    self.barChartView.dataSource = self;
    self.barChartView.delegate = self;
    self.barChartView.minimumValue = 0.0f;
    
    StreamAccessory *st = [[StreamAccessory alloc] initText:[[aggEvent.events objectAtIndex:0] eventBreadcrumbs] color:[[[aggEvent.events objectAtIndex:0] stream] getColor]];
    [self addSubview:st];
    
    NSDate *d = [[aggEvent.events objectAtIndex:0] eventDate];
    StreamAccessory *date = [[StreamAccessory alloc] initText:[[NotesAppController sharedInstance].dateFormatter stringFromDate:d] color:nil];
    [self addSubview:date];
    
    [self.barChartView reloadData];
    
}

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [self.aggEvents.events count];
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    return fabsf([((PYEvent*)[self.aggEvents.events objectAtIndex:index]).eventContent floatValue]);
}

-(UIColor*) barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return self.color;
}

@end
