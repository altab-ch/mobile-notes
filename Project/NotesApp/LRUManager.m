//
//  LRUManager.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/15/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "DataService.h"

#define kLRUFileName @"LRUData1.2.dat"

@interface LRUManager ()

@property (nonatomic, strong) NSMutableArray *lruArray;

- (void)initObject;
- (void)saveToDisc;
- (void)readFromDisc;

@end

@implementation LRUManager

+ (LRUManager*)sharedInstance
{
    static LRUManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LRUManager alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}

- (void)initObject
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogoutNotification:)
                                                 name:kUserDidLogoutNotification
                                               object:nil];
    [self readFromDisc];
}



-(void)userDidLogoutNotification:(NSNotification *)notification
{
    [self clearAllLRUEntries];
}

- (void)saveToDisc
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *arrayFileName = [documentsDirectory stringByAppendingPathComponent:kLRUFileName];
    BOOL result = [NSKeyedArchiver archiveRootObject:self.lruArray toFile:arrayFileName];
    NSLog(@"result: %d",result);
}

- (void)readFromDisc
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *arrayFileName = [documentsDirectory stringByAppendingPathComponent:kLRUFileName];
    self.lruArray = [NSKeyedUnarchiver unarchiveObjectWithFile:arrayFileName];
    if(!self.lruArray)
    {
        self.lruArray = [NSMutableArray array];
    }
}

#pragma mark - Public API

- (void)addUserHistoryEntry:(UserHistoryEntry *)entry
{
    UserHistoryEntry *entryToDelete = nil;
    NSString *entryComparableString = [entry comparableString];
    for(UserHistoryEntry *oldEntry in self.lruArray)
    {
        if([[oldEntry comparableString] isEqualToString:entryComparableString])
        {
            entryToDelete = oldEntry;
            break;
        }
    }
    if(entryToDelete)
    {
        [self.lruArray removeObject:entryToDelete];
    }
    [self.lruArray insertObject:entry atIndex:0];
    [self saveToDisc];
}

- (void)fetchLRUEntriesWithCompletionBlock:(void (^)(void))block
{
    block();
}

- (NSArray*)lruEntries
{
    return self.lruArray;
}

- (void)clearAllLRUEntries
{
    [self.lruArray removeAllObjects];
    [self saveToDisc];
}

- (void)removeObjectFromLruEntriesAtIndex:(NSUInteger)index
{
    [self.lruArray removeObjectAtIndex:index];
    [self saveToDisc];
}

@end
