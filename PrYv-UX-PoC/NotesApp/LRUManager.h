//
//  LRUManager.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/15/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserHistoryEntry;

@interface LRUManager : NSObject

@property (nonatomic, readonly) NSArray *lruEntries;

+ (LRUManager*)sharedInstance;
- (void)addUserHistoryEntry:(UserHistoryEntry*)entry;
- (void)fetchLRUEntriesWithCompletionBlock:(void (^)(void))block;
- (void)clearAllLRUEntries;
- (void)removeObjectFromLruEntriesAtIndex:(NSUInteger)index;
- (NSArray*)lruEntries;

@end
