//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PYEventTypes.h>
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYStream.h>
#import <PryvApiKit/PYEvent.h>
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"
#import "PYEvent+Helper.h"

#define kStreamListCacheTimeout 60 * 60 //60 minutes

NSString *const kSavingEventActionFinishedNotification = @"kSavingEventActionFinishedNotification";

@interface DataService ()


@end

@implementation DataService

+ (DataService*)sharedInstance
{
    static DataService *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DataService alloc] init];
    });
    return _sharedInstance;
}



- (void)saveEventAsShortcut:(PYEvent *)event andShouldTakePictureFlag:(BOOL)shouldTakePictureFlag
{
    UserHistoryEntry *entry = [[UserHistoryEntry alloc] initWithEvent:event];
    [[LRUManager sharedInstance] addUserHistoryEntry:entry];
}
@end
