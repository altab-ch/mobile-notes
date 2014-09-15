//
//  LineCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 15.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "LineCell.h"
#import "JBLineChartView.h"
#import "StreamAccessory.h"
#import "PYStream+Helper.h"
#import "GraphAggregateEvents.h"

@interface LineCell () <JBLineChartViewDataSource, JBLineChartViewDelegate>

@property (nonatomic, strong) IBOutlet JBLineChartView *lineChartView;
@property (nonatomic, strong) UIColor *lineColor, *fillColor;

@end

@implementation LineCell

- (void)updateWithAggregateEvent:(GraphAggregateEvents*)aggEvent
{
    [super updateWithEvent:[aggEvent.events objectAtIndex:0]];
    
    self.aggEvents = aggEvent;
    self.lineColor = [UIColor colorWithRed:189.0/255.0 green:9.0/255.0 blue:38.0/255.0 alpha:0.8];
    self.fillColor = [UIColor colorWithRed:189.0/255.0 green:9.0/255.0 blue:38.0/255.0 alpha:0.5];
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    self.lineChartView.minimumValue = 0.0f;
    
    StreamAccessory *st = [[StreamAccessory alloc] initText:[[aggEvent.events objectAtIndex:0] eventBreadcrumbs] color:[[[aggEvent.events objectAtIndex:0] stream] getColor]];
    [self addSubview:st];
    
    NSDate *d = [[aggEvent.events objectAtIndex:0] eventDate];
    StreamAccessory *date = [[StreamAccessory alloc] initText:[[NotesAppController sharedInstance].dateFormatter stringFromDate:d] color:nil];
    [self addSubview:date];
    
    [self.lineChartView reloadData];
    
}

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1; // number of lines in chart
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [self.aggEvents.events count];
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [((PYEvent*)[self.aggEvents.events objectAtIndex:horizontalIndex]).eventContent floatValue];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return NO;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.lineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.fillColor;
}

@end
