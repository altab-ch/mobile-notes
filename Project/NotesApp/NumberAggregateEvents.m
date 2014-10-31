//
//  NumberAggregateEvents.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NumberAggregateEvents.h"
#import "PYStream+Helper.h"
#import <PryvApiKit/PYConnection+Streams.h>

@implementation NumberAggregateEvents

-(NSString*) historyLocalized
{
    switch (self.history) {
        case HistoryYear:
            return NSLocalizedString(@"year", nil);
            break;
            
        case HistoryMonth:
            return NSLocalizedString(@"month", nil);
            break;
            
        case HistoryWeek:
            return NSLocalizedString(@"week", nil);
            break;
            
        case HistoryDay:
            return NSLocalizedString(@"day", nil);
            break;
            
        default:
            break;
    }
}

-(NSString*) intervalLocalized
{
    switch (self.interval) {
        case IntervalMonth:
            return NSLocalizedString(@"month", nil);
            break;
            
        case IntervalWeek:
            return NSLocalizedString(@"week", nil);
            break;
            
        case IntervalDay:
            return NSLocalizedString(@"day", nil);
            break;
            
        case IntervalHour:
            return NSLocalizedString(@"hour", nil);
            break;
            
        default:
            break;
    }
}

-(NSString*) typeLocalized
{
    switch (self.transform) {
        case TransformNone:
            return NSLocalizedString(@"None", nil);
            break;
            
        case TransformAverage:
            return NSLocalizedString(@"AverageBy", nil);
            break;
            
        case TransformSum:
            return NSLocalizedString(@"SumBy", nil);
            break;
            
        default:
            break;
    }
}

-(NSString*) graphStyleLocalized
{
    switch (self.graphStyle) {
        case GraphStyleLine:
            return NSLocalizedString(@"Line", nil);
            break;
            
        case GraphStyleBar:
            return NSLocalizedString(@"Bar", nil);
            break;
            
        case GraphStyleArea:
            return NSLocalizedString(@"Bar", nil);
            break;
            
        case GraphStyleLineJoined:
            return NSLocalizedString(@"Bar", nil);
            break;
            
        default:
            break;
    }
}

-(GraphStyle) graphStyleFromClientData:(NSDictionary*)data withPyType:(NSString*)key
{
    NSString * graphStyle = [[[[data objectForKey:@"pryv-browser:charts"] objectForKey:key] objectForKey:@"settings"] objectForKey:@"style"];
    if ([graphStyle isEqualToString:@"line"])
        return GraphStyleLine;
    else
        return GraphStyleBar;
}

-(Transform) transformFromClientData:(NSDictionary*)data withPyType:(NSString*)key
{
    NSString * transform = [[[[data objectForKey:@"pryv-browser:charts"] objectForKey:key] objectForKey:@"settings"] objectForKey:@"transform"];
    if ([transform isEqualToString:@""])
        return TransformNone;
    else if ([transform isEqualToString:@"sum"])
        return TransformSum;
    else
        return TransformAverage;
}

-(id) initWithEvent:(PYEvent*)event
{
    self = [super initWithEvent:event];
    if (self) {
        
        _stream = [event stream];
        
        if (![_stream.clientData objectForKey:@"pryv-browser:charts"]) {
            NSDictionary *chartsDic = [self defaultClientDataCharts:self.pyType.key];
            NSMutableDictionary *dic = [_stream.clientData mutableCopy];
            [dic setValue:chartsDic forKey:@"pryv-browser:charts"];
            [_stream setClientData:dic];
            [[NotesAppController sharedInstance].connection streamSaveModifications:_stream successHandler:nil errorHandler:nil];
        }
        
        _graphStyle = [self graphStyleFromClientData:_stream.clientData withPyType:self.pyType.key];
        _transform = [self transformFromClientData:_stream.clientData withPyType:self.pyType.key];
        self.interval = IntervalHour;
        self.history = HistoryDay;
        //self.color = [[[self.events objectAtIndex:0] stream] getColor];
        
        if (self.history == HistoryDay) {
            NSDate *result = [event eventDate];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitMinute|NSCalendarUnitSecond   fromDate:result];
            [components setHour:0];
            [components setMinute:0];
            [components setSecond:0];
            
            self.startDate = [calendar dateFromComponents:components];
            [components setHour:24];
            self.endDate = [calendar dateFromComponents:components];
        }
    }
    return self;
}

-(BOOL) accept:(PYEvent *)event
{
    if ([event.pyType.key isEqualToString:((PYEvent*)[self.events objectAtIndex:0]).pyType.key]) {
        [self.events addObject:event];
        return YES;
    }
    return NO;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"nb event %lu, key %@", (unsigned long)[self.events count], self.pyType.key];
}

-(void) sort
{
    [super sort];
    NSUInteger nbValues = [self nbValues];
    self.sortedEvents = [NSMutableArray arrayWithCapacity:nbValues];
    for (int i = 0; i < nbValues; i++) [self.sortedEvents addObject:[NSMutableArray array]];
    NSInteger index = 0;
    for (PYEvent* event in self.events) {
        if (self.transform) index = [self getHourFromEvent:event];
        [[self.sortedEvents objectAtIndex:index] addObject:event];
        if (!self.transform) index++;
    }
    
    if (!(self.graphStyle == GraphStyleLine && self.transform == TransformSum)) {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSArray* ar in self.sortedEvents) {
            if ([ar count]) {
                [temp addObject:ar];
            }
        }
        self.sortedEvents = temp;
    }
    
}

-(NSUInteger) nbValues
{
    if (self.transform) {
        switch (self.history) {
            case HistoryDay:
                return 24;
                break;
                
            default:
                break;
        }
    }
    return [self.events count];
}

-(NSInteger) getHourFromEvent:(PYEvent*)event
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:event.eventDate];
    NSInteger hour = [components hour];
    //NSInteger minute = [components minute]; same for day month year
    return hour;
}

-(NSUInteger) getDayFromEvent:(PYEvent*)event
{
    return 22;
}

-(NSUInteger) getMonthFromEvent:(PYEvent*)event
{
    return 22;
}

-(NSDictionary*) defaultClientDataCharts:(NSString*)pyType
{
    return [self clientDataChartsWithStyle:@"bar" transform:@"average" pyType:pyType];
}

-(NSDictionary*)clientDataChartsWithStyle:(NSString*)style transform:(NSString*)transform pyType:(NSString*)pyType
{
    NSDictionary *result = @{pyType:@{@"settings":@{@"color":@"#c0392b",
                                                    @"style":style,
                                                    @"transform":transform,
                                                    @"interval":@"hourly",
                                                    @"history":@"day"
                                                    }
                                      }
                             };
    return result;
}

-(void)saveStreamData
{
    NSString *style;
    switch (_graphStyle) {
        case 0:
            style = @"bar";
            break;
        case 1:
            style = @"line";
            break;
            
        default:
            break;
    }
    
    NSString *transform;
    switch (_transform) {
        case 0:
            transform = @"";
            break;
        case 1:
            transform = @"average";
            break;
            
        case 2:
            transform = @"sum";
            break;
            
        default:
            break;
    }
    
    NSDictionary *chartsDic = [self clientDataChartsWithStyle:style transform:transform pyType:self.pyType.key];
    NSMutableDictionary *dic = [_stream.clientData mutableCopy];
    [dic setValue:chartsDic forKey:@"pryv-browser:charts"];
    [_stream setClientData:dic];
    [[NotesAppController sharedInstance].connection streamSaveModifications:_stream successHandler:nil errorHandler:nil];
}

-(void) setTransform:(Transform)transform
{
    _transform = transform;
    [self saveStreamData];
    [self sort];
}

-(void) setGraphStyle:(GraphStyle)graphStyle
{
    _graphStyle = graphStyle;
    [self saveStreamData];
    [self sort];
}


@end
