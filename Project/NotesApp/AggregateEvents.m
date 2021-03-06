//
//  AggregateEvents.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateEvents.h"
#import "NumberAggregateEvents.h"
#import "MapAggregateEvents.h"
#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"

@implementation AggregateEvents

+ (AggregateEvents*) createWithEvent:(PYEvent*)event {
    if ([event.pyType isNumerical])
        return [[NumberAggregateEvents alloc] initWithEvent:event];
    
    else if([event.pyType.key isEqualToString:@"position/wgs84"])
        return [[MapAggregateEvents alloc] initWithEvent:event];
    
    else
        NSLog(@"wrong type");
    
    return nil;
}

-(id) initWithEvent:(PYEvent*)event
{
    self = [super init];
    if (self) {
        self.events = [NSMutableArray array];
        [self.events addObject:event];
        self.pyType = event.pyType;
        self.breadCrumbs = event.stream.breadcrumbs;
        self.streamColor = event.stream.getColor;
    }
    return self;
}

-(BOOL) accept:(PYEvent *)event
{
    return NO;
}

-(void) sort
{
    [self.events sortUsingComparator:^NSComparisonResult(PYEvent* a, PYEvent* b) {
        return [a.eventDate compare:b.eventDate]==NSOrderedDescending;
    }];
}

@end
