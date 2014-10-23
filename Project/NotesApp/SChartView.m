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
@property (nonatomic) ChartViewContext context;
@property (nonatomic) BOOL firstLaunch;
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
    
    __block NSDate *min = nil;
    __block NSDate *max = nil;
    [self dateMinMax:^(NSDate* minDate, NSDate* maxDate){
        min = minDate;
        max = maxDate;
    }];
    
    __block NSNumber *minVal = nil;
    __block NSNumber *maxVal = nil;
    [self valueMinMax:^(NSNumber* minValue, NSNumber* maxValue){
        minVal = minValue;
        maxVal = maxValue;
    }];
    
    
    SChartDateRange* dateRange = [[SChartDateRange alloc]initWithDateMinimum:min andDateMaximum:max];
    SChartDateTimeAxis *xAxis = [[xTimeAxis alloc] initWithRange:dateRange];
    
    
    SChartNumberRange* numberRange = [[SChartNumberRange alloc] initWithMinimum:minVal andMaximum:maxVal];
    SChartNumberAxis* yAxis = [[SChartNumberAxis alloc] initWithRange:numberRange];
    
    
    if (context == ChartViewContextBrowser) {
        self.userInteractionEnabled = NO;
        xAxis.style.majorTickStyle.showLabels = NO;
        xAxis.style.majorTickStyle.showTicks = NO;
        yAxis.style.majorTickStyle.showLabels = NO;
        yAxis.style.majorTickStyle.showTicks = NO;
        yAxis.style.lineColor = [UIColor whiteColor];
    }else{
        xAxis.enableGesturePanning = YES;
        xAxis.enableGestureZooming = YES;
        yAxis.style.lineColor = [UIColor whiteColor];
    }
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        self.yAxis = yAxis;
        self.xAxis = xAxis;
    //});
}

-(void) updateWithAggregateEvents:(NumberAggregateEvents*)aggEvents withContext:(ChartViewContext)context
{
    self.aggEvents = aggEvents;
    self.context = context;
    self.firstLaunch = true;
    self.delegate = self;
    self.datasource = self;
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initChartWithContext:context];
    //});
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    /*if (self.context == ChartViewContextDetail && self.firstLaunch)
    {
        [[((SChartSeries*)[self.series objectAtIndex:0]).dataSeries.dataPoints objectAtIndex:0] setSelected:YES];
        
        NSArray *events = [self.aggEvents.sortedEvents objectAtIndex:0];
        [self.chartDelegate didSelectEvents:events
                                   withType:[self getType]
                                      value:[NSString stringWithFormat:@"%f",[self getValueForIndex:0]]
                                       date:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:[self getDateForIndex:0]]];
        self.firstLaunch = false;
    }*/
    
    //[self selectClosePoint:[self.aggEvents.sortedEvents count]-1];
    
}

-(void) selectClosePoint:(NSInteger)index
{
    if ([[self.aggEvents.sortedEvents objectAtIndex:index] count]) {
        [self selectPoint:index];
    }else
    {
        [self selectPoint:[self findClosestEvents:index]];
    
    }
}

-(NSInteger) findClosestEvents:(NSInteger)index
{
    NSInteger up = index+1;
    while (up < [self.aggEvents.sortedEvents count] && ![[self.aggEvents.sortedEvents objectAtIndex:up] count])
        up++;
    
    NSInteger down = index-1;
    while (down >= 0 && ![[self.aggEvents.sortedEvents objectAtIndex:down] count])
        down--;
    
    if (up >= [self.aggEvents.sortedEvents count]) {
        if (down < 0) {
            return index;
        }
        return down;
    }
    
    if (down < 0) {
        if (up >= [self.aggEvents.sortedEvents count]) {
            return index;
        }
        return up;
    }
    
    if(index-down > up-index)
        return up;
    return down;
}

-(void) selectPoint:(NSInteger)index
{
    if (self.firstLaunch) {
        NSInteger lastVal = [self findClosestEvents:[self.aggEvents.sortedEvents count]-1];
        [[((SChartSeries*)[self.series objectAtIndex:0]).dataSeries.dataPoints objectAtIndex:lastVal] setSelected:NO];
        
        
        
        [[((SChartSeries*)[self.series objectAtIndex:0]).dataSeries.dataPoints objectAtIndex:index] setSelected:YES];
        NSArray *events = [self.aggEvents.sortedEvents objectAtIndex:index];
        [self.chartDelegate didSelectEvents:events
                                   withType:[self getType]
                                      value:[NSString stringWithFormat:@"%@",[[NotesAppController sharedInstance].numf stringFromNumber:[NSNumber numberWithFloat:[self getValueForIndex:index]]]]
                                       date:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:[self getDateForIndex:index]]];
        self.firstLaunch = false;
    }
}

#pragma mark - SChartDelegate mathods

- (void)sChart:(ShinobiChart *)chart toggledSelectionForPoint:(SChartDataPoint *)dataPoint inSeries:(SChartSeries *)series
atPixelCoordinate:(CGPoint)pixelPoint
{
    self.firstLaunch=true;
    [self selectClosePoint:dataPoint.index];
    
}

#pragma mark - SChartDatasource methods

- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart {
    return 1;
}

-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index {
    
    SChartSeries *chartSeries;
    
    if (self.aggEvents.graphStyle == GraphStyleLine) {
        SChartLineSeries *lineChartSeries = [[SChartLineSeries alloc] init];
        //lineSeries.stackIndex = [NSNumber numberWithInt:1];
        //lineSeries.crosshairEnabled = YES;
        lineChartSeries.selectionMode = SChartSelectionPoint;
        
        SChartLineSeriesStyle *style = [SChartLineSeriesStyle new];
        style.lineColor = self.aggEvents.streamColor;
        
        style.pointStyle = [SChartPointStyle new];
        style.pointStyle.showPoints = YES;
        style.pointStyle.color = self.aggEvents.streamColor;;
        style.pointStyle.radius = @(5);
        
        style.selectedPointStyle = [SChartPointStyle new];
        style.selectedPointStyle.showPoints = YES;
        style.selectedPointStyle.color = [UIColor redColor];
        style.selectedPointStyle.radius = @(8);
        
        [lineChartSeries setStyle:style];
        
        return lineChartSeries;
    }else
    {
        SChartColumnSeries *columnChartSeries = [[SChartColumnSeries alloc] init];
        //lineSeries.stackIndex = [NSNumber numberWithInt:1];
        //lineSeries.crosshairEnabled = YES;
        columnChartSeries.selectionMode = SChartSelectionPoint;
        
        SChartColumnSeriesStyle *style = [SChartColumnSeriesStyle new];
        style.areaColor = self.aggEvents.streamColor;
        SChartColumnSeriesStyle *selectedStyle = [SChartColumnSeriesStyle new];
        selectedStyle.areaColor = [UIColor redColor];
        
        [columnChartSeries setStyle:style];
        [columnChartSeries setSelectedStyle:selectedStyle];
        
        return columnChartSeries;
    }
    
    return chartSeries;
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
    if (self.aggEvents.graphStyle == GraphStyleLine && self.aggEvents.transform == TransformAverage) {
        NSInteger result = 0;
        for (NSArray *ar in self.aggEvents.sortedEvents) {
            if ([ar count]) {
                result++;
            }
        }
        return result;
    }
    return self.aggEvents.sortedEvents.count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    
    if (self.aggEvents.graphStyle == GraphStyleLine && self.aggEvents.transform == TransformAverage) {
        NSInteger index = 0;
        NSInteger valid = 0;
        for (NSArray *ar in self.aggEvents.sortedEvents) {
            if ([ar count]) {
                if (valid == dataIndex) return [self dataPointForDate:[self getDateForIndex:index] andValue:[NSNumber numberWithFloat:[self getValueForIndex:index]]];
                valid++;
            }
            index++;
        }
    }
    
    SChartDataPoint* datapoint = [self dataPointForDate:[self getDateForIndex:dataIndex]
                                               andValue:[NSNumber numberWithFloat:[self getValueForIndex:dataIndex]]];
    
    return datapoint;
}

- (float)sChartRadiusForDataPoint:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    if (self.aggEvents.graphStyle == GraphStyleLine && self.aggEvents.transform == TransformAverage) {
        return 5;
    }
    
    if ([[self.aggEvents.sortedEvents objectAtIndex:dataIndex] count] == 0)
        return 1;
    
    return 5;
}

- (float)sChartInnerRadiusForDataPoint:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    if (self.aggEvents.graphStyle == GraphStyleLine && self.aggEvents.transform == TransformAverage) {
        return 3;
    }
    
    if ([[self.aggEvents.sortedEvents objectAtIndex:dataIndex] count] == 0)
        return 0.1;
    
    return 3;
}

#pragma mark - Utils

-(void) dateMinMax:(void (^)(NSDate* minDate, NSDate* maxDate))block
{
    NSMutableArray* dates = [NSMutableArray array];
    for (int i=0; i<self.aggEvents.sortedEvents.count; i++) {
        [dates addObject:[self getDateForIndex:i]];
    }
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
    NSArray *reverseOrder=[dates sortedArrayUsingDescriptors:descriptors];
    double diff = ([[reverseOrder objectAtIndex:[reverseOrder count]-1] timeIntervalSince1970]-[[reverseOrder objectAtIndex:0] timeIntervalSince1970])*0.05;
    block([[reverseOrder objectAtIndex:0] dateByAddingTimeInterval:-diff], [[reverseOrder objectAtIndex:[reverseOrder count]-1] dateByAddingTimeInterval:diff]);
}

-(void) valueMinMax:(void (^)(NSNumber* minValue, NSNumber* maxValue))block
{
    CGFloat min = [self minValue];
    CGFloat max = [self maxValue];
    CGFloat padding = (max-min)*0.05;
    block([NSNumber numberWithFloat:min-padding], [NSNumber numberWithFloat:max+padding]);
}

-(CGFloat)minValue
{
    CGFloat result = CGFLOAT_MAX;
    
    if (self.aggEvents.transform) {
        for (int i=0; i<[self.aggEvents.sortedEvents count];i++) {
            if (![[self.aggEvents.sortedEvents objectAtIndex:i] count] && result>0) result = 0;
            else if (result > [self getValueForIndex:i]) result = [self getValueForIndex:i];
        }
    }else{
        for (PYEvent* event in self.aggEvents.events) {
            if (result > [event.eventContent floatValue]) result = [event.eventContent floatValue];
        }
    }
    
    return result;
}

-(CGFloat)maxValue
{
    CGFloat result = CGFLOAT_MIN;
    
    if (self.aggEvents.transform) {
        for (int i=0; i<[self.aggEvents.sortedEvents count];i++) {
            if (![[self.aggEvents.sortedEvents objectAtIndex:i] count] && result<0) result = 0;
            else if (result < [self getValueForIndex:i]) result = [self getValueForIndex:i];
        }
    }else{
        for (PYEvent* event in self.aggEvents.events) {
            if (result < [event.eventContent floatValue]) result = [event.eventContent floatValue];
        }
    }
    
    return result;
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
