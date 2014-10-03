//
//  NumberAggregateEvents.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NumberAggregateEvents.h"
#import "PYStream+Helper.h"

@implementation NumberAggregateEvents

-(id) initWithEvent:(PYEvent*)event
{
    self = [super initWithEvent:event];
    if (self) {
        self.graphStyle = GraphStyleLine;
        self.transform = TransformAverage;
        self.interval = IntervalHour;
        self.history = HistoryDay;
        //self.color = [[[self.events objectAtIndex:0] stream] getColor];
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


@end
