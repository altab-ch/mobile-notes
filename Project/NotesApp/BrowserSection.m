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

-(void) addEvent:(PYEvent*)event
{
    [self addEvent:event withSort:NO];
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
        return [self addAggregateEvent:event withSort:sort];
    
    return -1;
}

-(NSInteger) addAggregateEvent:(PYEvent*)event withSort:(BOOL)sort
{
    __block NSInteger accepted = -1;
    [self.aggregateEventsList enumerateObjectsUsingBlock:^(AggregateEvents* aggEvents, NSUInteger idx, BOOL* stop){
        if ([aggEvents accept:event]) {
            if (sort) [aggEvents sort];
            accepted = idx;
            *stop = YES;
        }
    }];
    
    if (accepted == -1) {
        AggregateEvents* ag =[AggregateEvents createWithEvent:event];
        if (ag) {
            [self.aggregateEventsList addObject:ag];
            accepted = [self.aggregateEventsList count]-1;
        }
    }
    
    return accepted;
}

-(void) sortAll
{
    [self sortSingleEvents];
    [self sortAggregateEvents];
}

-(void) sortAggregateEvents
{
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

-(id) getEventsForRow:(NSUInteger)row
{
    if (row < [self.aggregateEventsList count])
        return [[self.aggregateEventsList objectAtIndex:row] events];
    
    return [self.singleEvents objectAtIndex:row-[self.aggregateEventsList count]];
}

-(NSUInteger) numberOfRow
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
