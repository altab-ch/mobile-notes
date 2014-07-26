//
//  DataGroupingManager.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataGroupingManager.h"
#import "StreamGroupingManager.h"

NSString *const kDataGroupingManagerDidFinishGrouping = @"kDataGroupingManagerDidFinishGrouping";

@interface DataGroupingManager ()

@end

@implementation DataGroupingManager

+ (id<DataGroupingDataSource>)groupingManagerWithDatgroupingType:(DataGroupingType)dataGroupingType {
    switch (dataGroupingType) {
        case ChannelGrouping:
            return [[StreamGroupingManager alloc] init];
            break;
        default:
            return nil;
            break;
    }
}

+ (id<DataGroupingDataSource>)channelGroupingManager {
    return [DataGroupingManager groupingManagerWithDatgroupingType:ChannelGrouping];
}

@end
