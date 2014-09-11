//
//  BrowserSection.m
//  NotesApp
//
//  Created by Mathieu Knecht on 09.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowserSection.h"
#import "PYEvent+Helper.h"
#import "AggregateEvents.h"
#import "NumberAggregateEvents.h"
#import "MapAggregateEvents.h"

@interface BrowserSection ()

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, strong) NSMutableArray *singleEvents;
@property(nonatomic, strong) NSMutableArray *aggregateEventsList;
@property(nonatomic, strong) NSString* title;

@end

@implementation BrowserSection

-(id) initWithDate:(NSDate*)date
{
    self=[super init];
    if (self) {
        self.date = date;
        self.key = [[NotesAppController sharedInstance].sectionKeyFormatter stringFromDate:self.date];
        self.title = [[NotesAppController sharedInstance].sectionTitleFormatter stringFromDate:self.date];
        self.singleEvents = [NSMutableArray array];
        self.aggregateEventsList = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isEqual:(BrowserSection*)anObject
{
    return [self.key isEqualToString:anObject.key];
}

- (NSUInteger)hash
{
    return [self.key hash];
}

-(BOOL) isSingleEvent:(PYEvent*)event
{
    if (event.eventDataType == EventDataTypeImage || event.eventDataType == EventDataTypeNote)
        return YES;
    return NO;
}

-(NSInteger) addEvent:(PYEvent*)event withSort:(BOOL)sort
{
    if ([self isSingleEvent:event]){
        [self.singleEvents addObject:event];
        if (sort) {
            [self sortSingleEvents];
            return [self.singleEvents indexOfObject:event]+[self.aggregateEventsList count];
        }
        return -1;
    }else
        return [self addAggregateEvent:event];
    
    return -1;
}

-(NSInteger) addAggregateEvent:(PYEvent*)event
{
    __block NSInteger accepted = -1;
    [self.aggregateEventsList enumerateObjectsUsingBlock:^(AggregateEvents* aggEvents, NSUInteger idx, BOOL* stop){
        if ([aggEvents accept:event]) {
            accepted = idx;
            *stop = YES;
        }
    }];
    
    if (accepted == -1) {
        if ([event.pyType isNumerical])
            [self.aggregateEventsList addObject:[[NumberAggregateEvents alloc] initWithEvent:event]];
        else if([event.pyType.key isEqualToString:@"position/wgs84"])
            [self.aggregateEventsList addObject:[[MapAggregateEvents alloc] initWithEvent:event]];
        
        accepted = [self.aggregateEventsList count]-1;
    }
    
    return accepted;
}

-(void) sort
{
    [self sortSingleEvents];
    
    [self.aggregateEventsList enumerateObjectsUsingBlock:^(AggregateEvents* aggEvents, NSUInteger idx, BOOL* stop){
        [aggEvents sort];
    }];
}

-(void) sortSingleEvents
{
    [self.singleEvents sortUsingComparator:^NSComparisonResult(PYEvent* a, PYEvent* b) {
        return [a.eventDate compare:b.eventDate]==NSOrderedDescending;
    }];
}

-(NSInteger) numberOfRow
{
    return [self.singleEvents count]+[self.aggregateEventsList count];
}

-(NSInteger) rowForEvent
{
    
    return [self.singleEvents count]+[self.aggregateEventsList count];
}

- (NSString *)description {
    __block NSString* result = [NSString stringWithFormat:@"Section : key : %@", self.key];
    if ([self.singleEvents count]) result = [result stringByAppendingFormat:@"\n Single Events : %d", [self.singleEvents count]];
    [self.singleEvents enumerateObjectsUsingBlock:^(PYEvent* event, NSUInteger idx, BOOL *stop){
        result = [result stringByAppendingFormat:@"\n   %@", event.pyType.key];
    }];
    if ([self.aggregateEventsList count]) result = [result stringByAppendingFormat:@"\n Aggregate Events : %d", [self.aggregateEventsList count]];
    [self.aggregateEventsList enumerateObjectsUsingBlock:^(AggregateEvents* agg, NSUInteger idx, BOOL* stop){
        if ([agg.events count]) {
            result = [result stringByAppendingFormat:@"\n   %@ : %d events", [[[agg.events objectAtIndex:0] pyType]key], [agg.events count]];
        }
        
    }];
    
    return result;
}


@end
