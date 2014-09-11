//
//  MapAggregateEvents.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "MapAggregateEvents.h"

@implementation MapAggregateEvents

-(BOOL) accept:(PYEvent *)event
{
    if ([event.pyType.key isEqualToString:@"position/wgs84"]) {
        [self.events addObject:event];
        return YES;
    }
    return NO;
}

@end
