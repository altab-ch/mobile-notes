//
//  NumberAggregateEvents.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NumberAggregateEvents.h"

@implementation NumberAggregateEvents

-(BOOL) accept:(PYEvent *)event
{
    if ([event.pyType isNumerical]) {
        [self.events addObject:event];
        return YES;
    }
    return NO;
}

@end
