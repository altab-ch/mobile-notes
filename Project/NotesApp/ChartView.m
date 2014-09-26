//
//  ChartView.m
//  NotesApp
//
//  Created by Mathieu Knecht on 19.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "ChartView.h"
#import "NumberAggregateEvents.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"

@interface ChartView () <UIGestureRecognizerDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate, JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) NumberAggregateEvents *aggEvents;
@property (nonatomic, strong) JBChartView *chartView;
@property (nonatomic) CGFloat newWidth;
@property (nonatomic) CGFloat newCenter;
@property (nonatomic) CGFloat newX;

@end

@implementation ChartView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.newWidth = 310;
        self.newCenter = 155;
        self.newX = 0;
    }
    return self;
}

-(void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    CGFloat newWidth = self.newWidth*((UIPinchGestureRecognizer*)sender).scale;
    if (newWidth<self.frame.size.width) newWidth = self.frame.size.width;
    CGFloat newX = (self.chartView.frame.origin.x-(newWidth-self.chartView.frame.size.width)/2.0);
    if (newX > 0)
        newX = 0;
    if (newX + self.chartView.frame.size.width < self.frame.size.width)
        newX = self.frame.size.width - self.chartView.frame.size.width;
    
    [self.chartView setFrame:CGRectMake(newX, 0, newWidth, self.frame.size.height)];
    [self.chartView reloadData];
    
    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled)
    {
        self.newWidth = self.chartView.frame.size.width;
        self.newX = self.chartView.frame.origin.x;
    }
    
    
}

-(void)handlePan:(UIPanGestureRecognizer*)sender
{
    CGFloat newX = self.newX + [sender translationInView:self.chartView].x;
    if (newX>0)
        newX = 0;
    if (newX + self.chartView.frame.size.width < self.frame.size.width)
        newX = self.frame.size.width - self.chartView.frame.size.width;
    
    [self.chartView setFrame:CGRectMake(newX, 0, self.chartView.frame.size.width, self.chartView.frame.size.width)];
    
    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled)
    {
        self.newCenter = self.chartView.frame.origin.x+self.chartView.frame.size.width/2;
        self.newX = self.chartView.frame.origin.x;
    }
    
}

-(void) updateWithAggregateEvents:(NumberAggregateEvents*)aggEvents
{
    self.aggEvents = aggEvents;

    if (self.aggEvents.graphStyle == GraphStyleLine || self.aggEvents.graphStyle == GraphStyleArea) {
        JBLineChartView *lineChartView = [[JBLineChartView alloc] init];
        [lineChartView setFrame:self.bounds];
        lineChartView.dataSource = self;
        lineChartView.delegate = self;
        lineChartView.minimumValue = 0.0f;
        
        [self addSubview:lineChartView];
        [lineChartView reloadData];
        self.chartView = lineChartView;
    }
    
    if (self.aggEvents.graphStyle == GraphStyleBar) {
        JBBarChartView *lineChartView = [[JBBarChartView alloc] init];
        [lineChartView setFrame:self.bounds];
        lineChartView.dataSource = self;
        lineChartView.delegate = self;
        lineChartView.minimumValue = 0.0f;
        
        [self addSubview:lineChartView];
        [lineChartView reloadData];
        self.chartView = lineChartView;
    }
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.chartView addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [pan setMinimumNumberOfTouches:2];
    [self.chartView addGestureRecognizer:pan];
    
}

#pragma mark Utils

-(CGFloat) getValueForIndex:(NSUInteger)index
{
    float result = 0;
    for (PYEvent* event in [self.aggEvents.sortedEvents objectAtIndex:index]) result += [event.eventContent floatValue];
    if (self.aggEvents.transform == TransformAverage && [self.aggEvents.sortedEvents objectAtIndex:index] && [[self.aggEvents.sortedEvents objectAtIndex:index] count]>0) result = result / [[self.aggEvents.sortedEvents objectAtIndex:index] count];
    return result;
}

-(NSString*) getType
{
    switch (self.aggEvents.transform) {
        case TransformAverage:
            return @"Average";
            break;
            
        case TransformSum:
            return @"Sum";
            break;
            
        default:
            break;
    }
    
    return @"Last";
}

-(NSString*) getDateDescriptionForIndex:(NSInteger)index
{
    NSString* date;
    if (!self.aggEvents.transform && [[self.aggEvents.sortedEvents objectAtIndex:index] count]>0) {
        date = [[NotesAppController sharedInstance].cellDateFormatter stringFromDate:[((PYEvent*)([[self.aggEvents.sortedEvents objectAtIndex:index] objectAtIndex:0])) eventDate]];
    }
    if (self.aggEvents.history == HistoryDay) {
        date = [NSString stringWithFormat:@"%d hour", (int)index];
    }
    
    return date;
}

#pragma mark JBLineDelegate

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1; // number of lines in chart
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [self.aggEvents.sortedEvents count];
}

-(CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [self getValueForIndex:horizontalIndex];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (self.aggEvents.graphStyle == GraphStyleArea) ? NO : YES;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.aggEvents.color;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (self.aggEvents.graphStyle == GraphStyleArea) ? self.aggEvents.color : nil;
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    [self.chartDelegate didSelectEvents:[self.aggEvents.sortedEvents objectAtIndex:horizontalIndex] withType:[self getType] value:[NSString stringWithFormat:@"%f",[self getValueForIndex:horizontalIndex]] date:[self getDateDescriptionForIndex:horizontalIndex]];
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    //[self displayEvent:[self.aggEvents.events count]-1];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return self.aggEvents.color;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 2.0;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.aggEvents.color;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return self.aggEvents.color;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionFillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return nil;//self.aggEvents.color;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return self.aggEvents.color;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewLineStyleSolid;
}

#pragma mark JBBarDelegate

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [self.aggEvents.sortedEvents count];
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    return fabsf([self getValueForIndex:index]);
}

-(UIColor*) barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return self.aggEvents.color;
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    [self.chartDelegate didSelectEvents:[self.aggEvents.sortedEvents objectAtIndex:index] withType:[self getType] value:[NSString stringWithFormat:@"%f",[self getValueForIndex:index]] date:[self getDateDescriptionForIndex:index]];
}

- (void)didDeselectBarChartView:(JBBarChartView *)barChartView
{
    //[self displayEvent:[self.aggEvents.events count]-1];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
