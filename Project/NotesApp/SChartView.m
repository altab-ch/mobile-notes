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
@property (nonatomic) BOOL firstLaunch, selection;
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
    
    self.backgroundColor = [UIColor whiteColor];
    
    
    __block NSNumber *minVal = nil;
    __block NSNumber *maxVal = nil;
    [self valueMinMax:^(NSNumber* minValue, NSNumber* maxValue){
        minVal = minValue;
        maxVal = maxValue;
    }];
    
    
    SChartDateRange* dateRange = [[SChartDateRange alloc]initWithDateMinimum:self.aggEvents.startDate andDateMaximum:self.aggEvents.endDate];
    SChartDateTimeAxis *xAxis = [[xTimeAxis alloc] initWithRange:dateRange];
    
    
    SChartNumberRange* numberRange = [[SChartNumberRange alloc] initWithMinimum:minVal andMaximum:maxVal];
    SChartNumberAxis* yAxis = [[SChartNumberAxis alloc] initWithRange:numberRange];
    
    
    if (self.aggEvents.graphStyle == GraphStyleBar) {
        [xAxis.style setInterSeriesPadding:@(1)];
        [xAxis.style setInterSeriesSetPadding:@(1)];
        [yAxis.style setInterSeriesPadding:@(1)];
        [yAxis.style setInterSeriesSetPadding:@(1)];
    }
    
    if (context == ChartViewContextBrowser) {
        self.userInteractionEnabled = NO;
        xAxis.style.majorTickStyle.showLabels = NO;
        xAxis.style.majorTickStyle.showTicks = NO;
        yAxis.style.majorTickStyle.showLabels = YES;
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
    self.selection = false;
    self.delegate = self;
    self.datasource = self;
    
    if ([self.aggEvents.events count]) {
        [self initChartWithContext:context];
    }
    
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if (self.firstLaunch)
    {
        NSInteger lastVal = [self findClosestEvents:[self.aggEvents.sortedEvents count]-1];
        [[((SChartSeries*)[self.series objectAtIndex:0]).dataSeries.dataPoints objectAtIndex:lastVal] setSelected:YES];
        
        NSArray *events = [self.aggEvents.sortedEvents objectAtIndex:lastVal];
        [self.chartDelegate didSelectEvents:events
                                   withType:[self getType]
                                      value:[[[NotesAppController sharedInstance] numf] stringFromNumber:@([self getValueForIndex:lastVal])]
                                       date:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:[self getDateForIndex:lastVal]]];
        self.firstLaunch = false;
    }
    
    //[self selectClosePoint:[self.aggEvents.sortedEvents count]-1];
    
}

-(void) selectClosePoint:(NSInteger)index
{
    if ([[self.aggEvents.sortedEvents objectAtIndex:index] count])
    {
        [self selectPoint:index];
    }
    else
    {
        [self selectPoint:[self findClosestEvents:index]];
    }
}

-(NSInteger) findClosestEvents:(NSInteger)index
{
    if ([[self.aggEvents.sortedEvents objectAtIndex:index] count]) return index;
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
    if (self.selection) {
        NSInteger lastVal = [self findClosestEvents:[self.aggEvents.sortedEvents count]-1];
        [[((SChartSeries*)[self.series objectAtIndex:0]).dataSeries.dataPoints objectAtIndex:lastVal] setSelected:NO];
        
        
        
        [[((SChartSeries*)[self.series objectAtIndex:0]).dataSeries.dataPoints objectAtIndex:index] setSelected:YES];
        NSArray *events = [self.aggEvents.sortedEvents objectAtIndex:index];
        
        [self.chartDelegate didSelectEvents:events
                                   withType:[self getType]
                                      value:[NSString stringWithFormat:@"%@",[[NotesAppController sharedInstance].numf stringFromNumber:[NSNumber numberWithFloat:[self getValueForIndex:index]]]]
                                       date:[[NotesAppController sharedInstance].cellDateFormatter stringFromDate:[self getDateForIndex:index]]];
        self.selection = false;
    }
}

#pragma mark - SChartDelegate mathods

- (void)sChart:(ShinobiChart *)chart toggledSelectionForPoint:(SChartDataPoint *)dataPoint inSeries:(SChartSeries *)series
atPixelCoordinate:(CGPoint)pixelPoint
{
    self.selection=true;
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
        columnChartSeries.selectionMode = SChartSelectionPoint;
        
        SChartColumnSeriesStyle *style = [SChartColumnSeriesStyle new];
        style.areaColor = self.aggEvents.streamColor;
        style.showAreaWithGradient = NO;
        SChartColumnSeriesStyle *selectedStyle = [SChartColumnSeriesStyle new];
        selectedStyle.areaColor = [UIColor redColor];
        selectedStyle.showAreaWithGradient = NO;
        
        [columnChartSeries setStyle:style];
        [columnChartSeries setSelectedStyle:selectedStyle];
        
        return columnChartSeries;
    }
    
    return chartSeries;
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex {
    
    return self.aggEvents.sortedEvents.count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex {
    
    SChartDataPoint* datapoint = [self dataPointForDate:[self getDateForIndex:dataIndex]
                                               andValue:[NSNumber numberWithFloat:[self getValueForIndex:dataIndex]]];
    
    return datapoint;
}

- (float)sChartRadiusForDataPoint:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    if ([[self.aggEvents.sortedEvents objectAtIndex:dataIndex] count] == 0)
        return 1;
    
    return 5;
}

- (float)sChartInnerRadiusForDataPoint:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    if ([[self.aggEvents.sortedEvents objectAtIndex:dataIndex] count] == 0)
        return 0.1;
    
    return 3;
}

#pragma mark - Utils

-(void) valueMinMax:(void (^)(NSNumber* minValue, NSNumber* maxValue))block
{
    CGFloat min = [self minValue];
    CGFloat max = [self maxValue];
    CGFloat padding = (max-min)*0.05;//0.05 padding coefficient
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
            return NSLocalizedString(@"Average", nil);
            break;
            
        case TransformSum:
            return NSLocalizedString(@"Sum", nil);
            break;
            
        default:
            break;
    }
    
    return NSLocalizedString(@"Last", nil);;
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
