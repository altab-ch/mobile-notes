//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PYClient.h>
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

@property (nonatomic, strong) NSArray *cachedStreams;
@property (nonatomic, strong) NSDate *lastStreamsUpdateTimestamp;

- (void)initObject;
- (void)executeCompletionBlockOnMainQueue:(DataServiceCompletionBlock)completionBlock withObject:(id)object andError:(NSError*)error;
- (void)populateStreamList:(NSMutableArray*)array withStreamsTree:(NSArray*)streams;

@end

@implementation DataService

+ (DataService*)sharedInstance
{
    static DataService *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DataService alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}

- (void)initObject
{
    
}




- (void)fetchAllStreamsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    [NotesAppController sharedConnectionWithID:nil
                   noConnectionCompletionBlock:^{
                       completionBlock(nil,[NSError errorWithDomain:PryvSDKDomain code:0 userInfo:nil]);
                   }
                           withCompletionBlock:^(PYConnection *connection)
     {
         if(self.cachedStreams && fabs([self.lastStreamsUpdateTimestamp timeIntervalSinceNow]) < kStreamListCacheTimeout)
         {
             completionBlock(self.cachedStreams, nil);
         }
         else
         {
             [connection streamsFromCache:^(NSArray *cachedStreamsList) {
                 //if(![[NotesAppController sharedInstance] isOnline])
                 //{
                 NSMutableArray *streams = [NSMutableArray array] ;
                 [self populateStreamList:streams withStreamsTree:cachedStreamsList];
                 completionBlock(streams, nil);
                 //}
                 
             } andOnline:^(NSArray *onlineStreamList) {
                 //if([[NotesAppController sharedInstance] isOnline])
                 //{
                 NSMutableArray *streams = [NSMutableArray array];
                 [self populateStreamList:streams withStreamsTree:onlineStreamList];
                 self.cachedStreams = streams;
                 [self executeCompletionBlockOnMainQueue:completionBlock withObject:streams andError:nil];
                 //}
                 
             } errorHandler:^(NSError *error) {
                 [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
             }];
             
         }
     }];
}

- (void)executeCompletionBlockOnMainQueue:(DataServiceCompletionBlock)completionBlock withObject:(id)object andError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock)
        {
            completionBlock(object, error);
        }
    });
}

- (void)saveEventAsShortcut:(PYEvent *)event andShouldTakePictureFlag:(BOOL)shouldTakePictureFlag
{
    UserHistoryEntry *entry = [[UserHistoryEntry alloc] initWithEvent:event];
    [[LRUManager sharedInstance] addUserHistoryEntry:entry];
}

- (void)invalidateStreamListCache
{
    self.cachedStreams = nil;
}

- (void)populateStreamList:(NSMutableArray *)array withStreamsTree:(NSArray *)streams
{
    for(PYStream *stream in streams)
    {
        [array addObject:stream];
        if([stream.children count] > 0)
        {
            [self populateStreamList:array withStreamsTree:stream.children];
        }
    }
}

@end
