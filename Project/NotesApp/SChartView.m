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

-(void) initChart
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
    
    //self.xAxis.style.majorTickStyle.showLabels = NO;
    //self.xAxis.style.majorTickStyle.showTicks = NO;
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

-(void) updateWithAggregateEvents:(NumberAggregateEvents*)aggEvents
{
    self.aggEvents = aggEvents;
    [self initChart];
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
    style.pointStyle.color = [UIColor whiteColor];
    style.pointStyle.radius = @(5);
    
    style.selectedPointStyle = [SChartPointStyle new];
    style.selectedPointStyle.showPoints = YES;
    style.selectedPointStyle.color = [UIColor orangeColor];
    style.selectedPointStyle.radius = @(15);
    
    [lineSeries setStyle:style];
    
    return lineSeries;
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
    return self.aggEvents.events.count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    SChartDataPoint* datapoint = [self dataPointForDate:[[self.aggEvents.events objectAtIndex:dataIndex] eventDate]
                                               andValue:[NSNumber numberWithFloat:[[[self.aggEvents.events objectAtIndex:dataIndex] eventContent] floatValue]]];
    
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

@end
