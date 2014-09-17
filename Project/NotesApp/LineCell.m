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

@interface LineCell () <JBLineChartViewDataSource, JBLineChartViewDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate>

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

    self.lineColor = [[[aggEvent.events objectAtIndex:0] stream] getColor];
    [self.backView2.layer setBorderWidth:1];
    [self.backView2.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    if (self.graphStyle == kAreaGraphStyle || self.graphStyle == kLineGraphStyle) {
        JBLineChartView *lineChartView = [[JBLineChartView alloc] init];
        self.fillColor = [UIColor colorWithRed:189.0/255.0 green:9.0/255.0 blue:38.0/255.0 alpha:0.5];
        [lineChartView setFrame:self.chartView.bounds];
        lineChartView.dataSource = self;
        lineChartView.delegate = self;
        lineChartView.minimumValue = 0.0f;
        
        [self.chartView addSubview:lineChartView];
        [lineChartView reloadData];
    }
    
    if (self.graphStyle == kBarGraphStyle) {
        JBBarChartView *lineChartView = [[JBBarChartView alloc] init];
        [lineChartView setFrame:self.chartView.bounds];
        lineChartView.dataSource = self;
        lineChartView.delegate = self;
        lineChartView.minimumValue = 0.0f;

        [self.chartView addSubview:lineChartView];
        [lineChartView reloadData];
    }
    
    StreamAccessory *st = [[StreamAccessory alloc] initText:[[aggEvent.events objectAtIndex:0] eventBreadcrumbs] color:[[[aggEvent.events objectAtIndex:0] stream] getColor]];
    [self addSubview:st];
    
    /*NSDate *d = [[aggEvent.events objectAtIndex:0] eventDate];
    StreamAccessory *date = [[StreamAccessory alloc] initText:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:d] color:nil];
    [self addSubview:date];*/
    
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
    return YES;
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
    return self.graphStyle == kAreaGraphStyle ? self.fillColor:nil;
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
    return self.lineColor;
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    [self displayEvent:horizontalIndex];
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    [self displayEvent:[self.aggEvents.events count]-1];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    [self displayEvent:index];
}

- (void)didDeselectBarChartView:(JBBarChartView *)barChartView
{
    [self displayEvent:[self.aggEvents.events count]-1];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return self.lineColor;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 2.0;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.lineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.lineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionFillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return nil;//self.lineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return self.lineColor;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewLineStyleSolid;
}

@end
