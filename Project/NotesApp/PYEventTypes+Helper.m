//
//  PYEventTypes+Helper.m
//  NotesApp
//
//  Created by Perki on 19.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//
#import "PYEventTypes+Helper.h"
#import "PYEventType.h"

@implementation PYEventTypes (Helper)


- (NSArray*) classesFilterWithNumericalValues {
    NSMutableSet* result = [[NSMutableSet alloc] init];
    for (NSString* typeKey in self.flat) {
        PYEventType* value = [self.flat objectForKey:typeKey];
        if (value.isNumerical) {
            [result addObject:[NSString stringWithFormat:@"%@/*", value.classKey]];
        }
    }
    
    return [result allObjects];
}

@end
