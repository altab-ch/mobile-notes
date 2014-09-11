//
//  AggregateEvents.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateEvents.h"

@implementation AggregateEvents

-(id) initWithEvent:(PYEvent*)event
{
    self = [super init];
    if (self) {
        self.events = [NSMutableArray array];
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
