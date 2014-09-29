//
//  SChartView.m
//  NotesApp
//
//  Created by Mathieu Knecht on 24.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "SChartView.h"
#import "NumberAggregateEvents.h"
#import "xTimeAxis.h"

@interface SChartView () <SChartDelegate, SChartDatasource>

@property (nonatomic, strong) NumberAggregateEvents *aggEvents;

@end

@implementation SChartView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void) initChartWithContext:(ChartViewContext)context
{
    self.title = @"";
    self.autoresizingMask =  ~UIViewAutoresizingNone;
    self.licenseKey = @"mu6q6ZGbUt7XLloMjAxNDEwMjRtYXRoaWV1LmtuZWNodEBnbWFpbC5jb20=0Hq+xXm5+B66t49SI6ka8chwMwFJLYwOjDMdVxaiX33+1RRND0Rxs7qCjTLrI2MeVCa2JLUN1UAZxGDKBznxk4TNMIChTKllDbT87yXe9FKyf3KdJdgUK6kWgvUR+IbwkcoLMFBf3yUMiF4MAAODmW6URYx8=BQxSUisl3BaWf/7myRmmlIjRnMU2cA7q+/03ZX9wdj30RzapYANf51ee3Pi8m2rVW6aD7t6Hi4Qy5vv9xpaQYXF5T7XzsafhzS3hbBokp36BoJZg8IrceBj742nQajYyV7trx5GIw9jy/V6r0bvctKYwTim7Kzq+YPWGMtqtQoU=PFJTQUtleVZhbHVlPjxNb2R1bHVzPnh6YlRrc2dYWWJvQUh5VGR6dkNzQXUrUVAxQnM5b2VrZUxxZVdacnRFbUx3OHZlWStBK3pteXg4NGpJbFkzT2hGdlNYbHZDSjlKVGZQTTF4S2ZweWZBVXBGeXgxRnVBMThOcDNETUxXR1JJbTJ6WXA3a1YyMEdYZGU3RnJyTHZjdGhIbW1BZ21PTTdwMFBsNWlSKzNVMDg5M1N4b2hCZlJ5RHdEeE9vdDNlMD08L01vZHVsdXM+PEV4cG9uZW50PkFRQUI8L0V4cG9uZW50PjwvUlNBS2V5VmFsdWU+"; // TODO: add your trial licence key here!
    
    self.backgroundColor = [UIColor whiteColor];
    
    // add X & Y axes, with explicit ranges so that the chart is initially rendered 'zoomed in'
    NSDate *date = [[self.aggEvents.events objectAtIndex:[self.aggEvents.events count]-1] eventDate];
    
    SChartDateRange* dateRange = [[SChartDateRange alloc]initWithDateMinimum:[NSDate dateWithTimeInterval:-80000 sinceDate:date]
                                                               andDateMaximum:[NSDate dateWithTimeInterval:7300 sinceDate:date]];
    SChartDateTimeAxis *xAxis = [[xTimeAxis alloc] initWithRange:dateRange];
    self.xAxis = xAxis;
    
    SChartNumberRange* numberRange = [[SChartNumberRange alloc] initWithMinimum:[self minValue] andMaximum:[self maxValue]];
    SChartNumberAxis* yAxis = [[SChartNumberAxis alloc] initWithRange:numberRange];
    yAxis.title = @"";
    [yAxis.style setLineColor:[UIColor whiteColor]];
    [yAxis setEnableGestureZooming:NO];
    self.yAxis = yAxis;
    
    self.xAxis.style.majorTickStyle.showLabels = NO;
    self.xAxis.style.majorTickStyle.showTicks = NO;
    yAxis.style.majorTickStyle.showLabels = NO;
    yAxis.style.majorTickStyle.showTicks = NO;
    
    // enable gestures
    //yAxis.enableGesturePanning = YES;
    //yAxis.enableGestureZooming = YES;
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    
    self.delegate = self;
    self.datasource = self;
}

-(void) updateWithAggregateEvents:(NumberAggregateEvents*)aggEvents withContext:(ChartViewContext)context
{
    self.aggEvents = aggEvents;
    [self initChartWithContext:context];
}

#pragma mark - SChartDelegate mathods

- (void)sChart:(ShinobiChart *)chart toggledSelectionForPoint:(SChartDataPoint *)dataPoint inSeries:(SChartSeries *)series
atPixelCoordinate:(CGPoint)pixelPoint
{
    NSLog(@"%@, %@", dataPoint, series);
}

- (void)sChart:(ShinobiChart *)chart toggledSelectionForSeries:(SChartSeries *)series nearPoint:(SChartDataPoint *)dataPoint atPixelCoordinate:(CGPoint)pixelPoint{
    NSLog(@"x value:%@",dataPoint.xValue);
    NSLog(@"y value:%@",dataPoint.yValue);
    //here you can create an label to show the x/y values or even can add an annotation
}

#pragma mark - SChartDatasource methods

- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
    return 1;
}

-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
    SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
    //lineSeries.stackIndex = [NSNumber numberWithInt:1];
    //lineSeries.crosshairEnabled = YES;
    lineSeries.selectionMode = SChartSelectionPoint;
    
    SChartLineSeriesStyle *style = [SChartLineSeriesStyle new];
    style.pointStyle = [SChartPointStyle new];
    style.pointStyle.showPoints = YES;
    style.pointStyle.color = [UIColor blueColor];
    style.pointStyle.radius = @(3);
    
    style.selectedPointStyle = [SChartPointStyle new];
    style.selectedPointStyle.showPoints = YES;
    style.selectedPointStyle.color = [UIColor redColor];
    style.selectedPointStyle.radius = @(6);
    
    [lineSeries setStyle:style];
    
    return lineSeries;
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
    return self.aggEvents.sortedEvents.count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    SChartDataPoint* datapoint = [self dataPointForDate:[self getDateForIndex:dataIndex]
                                               andValue:[NSNumber numberWithFloat:[self getValueForIndex:dataIndex]]];
    
    return datapoint;
}

#pragma mark - Utils

-(NSNumber*)minValue
{
    CGFloat result = CGFLOAT_MAX;
    for (PYEvent* event in self.aggEvents.events) {
        if (result > [event.eventContent floatValue]) result = [event.eventContent floatValue];
    }
    
    return [NSNumber numberWithFloat:result];
}

-(NSNumber*)maxValue
{
    CGFloat result = CGFLOAT_MIN;
    for (PYEvent* event in self.aggEvents.events) {
        if (result < [event.eventContent floatValue]) result = [event.eventContent floatValue];
    }
    
    return [NSNumber numberWithFloat:result];
}

- (SChartDataPoint*)dataPointForDate:(NSDate*)date andValue:(NSNumber*)value {
    SChartDataPoint* dataPoint = [SChartDataPoint new];
    dataPoint.xValue = date;
    dataPoint.yValue = value;
    return dataPoint;
}

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

-(NSDate*) getDateForIndex:(NSInteger)index
{
    NSDate* date;
    if (!self.aggEvents.transform && [[self.aggEvents.sortedEvents objectAtIndex:index] count]>0) {
        date = [((PYEvent*)([[self.aggEvents.sortedEvents objectAtIndex:index] objectAtIndex:0])) eventDate];
    }
    else if (self.aggEvents.history == HistoryDay) {
        NSDate *result = [((PYEvent*)([self.aggEvents.events objectAtIndex:0])) eventDate];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitMinute|NSCalendarUnitSecond   fromDate:result];
        [components setHour:index];
        [components setMinute:0];
        [components setSecond:0];
        
        date = [calendar dateFromComponents:components];
        //date = [NSString stringWithFormat:@"%d hour", (int)index];
    }
    
    return date;
}

@end
