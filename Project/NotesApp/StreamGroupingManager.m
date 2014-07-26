//
//  ChannelGroupingManager.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "StreamGroupingManager.h"
#import <PryvApiKit/PryvApiKit.h>

@interface StreamGroupingManager ()

@property (nonatomic, strong) NSMutableArray *streams;

@end

@implementation StreamGroupingManager

- (id)init {
    self = [super init];
    if(self) {
        self.streams = [NSMutableArray array];
    }
    return self;
}

- (NSString*)titleForGroupAtIndex:(NSInteger)index {
    return [[_streams objectAtIndex:index] name];
}

- (NSInteger)numberOfGroups {
    return [_streams count];
}

- (NSInteger)numberOfItemsInGroupAtIndex:(NSInteger)index {
    return [[[_streams objectAtIndex:index] children] count];
}

- (NSString*)titleForItemInGroupAtIndex:(NSInteger)groupIndex andItemIndex:(NSInteger)itemIndex {
    return [[[[_streams objectAtIndex:groupIndex] children] objectAtIndex:itemIndex] name];
}

- (void)performGroupingWithCompletionBlock:(void (^)(void))completionHandler {
    
}

@end
