//
//  DataGroupingManager.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDataGroupingManagerDidFinishGrouping;

typedef NS_ENUM(NSInteger, DataGroupingType) {
    ChannelGrouping = 1
};

@protocol DataGroupingDataSource <NSObject>

- (void)performGroupingWithCompletionBlock:(void (^)(void))completionHandler;
- (NSString*)titleForGroupAtIndex:(NSInteger)index;
- (NSInteger)numberOfGroups;
- (NSInteger)numberOfItemsInGroupAtIndex:(NSInteger)index;
- (NSString*)titleForItemInGroupAtIndex:(NSInteger)groupIndex andItemIndex:(NSInteger)itemIndex;

@end

@interface DataGroupingManager : NSObject

+ (id<DataGroupingDataSource>)groupingManagerWithDatgroupingType:(DataGroupingType)dataGroupingType;
+ (id<DataGroupingDataSource>)channelGroupingManager;

@end
