//
//  UserHistoryEntry.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UserHistoryEntry.h"
#import "NotesAppController.h"
#import "PYEvent+Helper.h"
#import <PryvApiKit/PYEventTypes.h>

#define kStreamIdKey @"StreamID"
#define kTagsKey @"TagsKey"
#define kDataTypeKey @"DataType"
#define kMeasurementGroupNameKey @"MeasurementGroupNameKey"
#define kMeasurementTypeNameKey @"MeasurementTypeNameKey"
#define kTypeStringKey @"TypeStringKey"

@implementation UserHistoryEntry

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:_streamId forKey:kStreamIdKey];
    [encoder encodeObject:_tags forKey:kTagsKey];
    [encoder encodeInteger:_dataType forKey:kDataTypeKey];
    [encoder encodeObject:_measurementGroupName forKey:kMeasurementGroupNameKey];
    [encoder encodeObject:_measurementTypeName forKey:kMeasurementTypeNameKey];
    [encoder encodeObject:_typeString forKey:kTypeStringKey];
}

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self)
    {
        self.streamId = [decoder decodeObjectForKey:kStreamIdKey];
        self.tags = [decoder decodeObjectForKey:kTagsKey];
        self.dataType = [decoder decodeIntegerForKey:kDataTypeKey];
        self.measurementGroupName = [decoder decodeObjectForKey:kMeasurementGroupNameKey];
        self.measurementTypeName = [decoder decodeObjectForKey:kMeasurementTypeNameKey];
        self.typeString = [decoder decodeObjectForKey:kTypeStringKey];
    }
    return self;
}

- (NSString*)comparableString
{
    NSArray *sortedTags = [self.tags sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableString *toReturn;
    if (! self.streamId) {
        toReturn = [NSMutableString stringWithString:@""];
        NSLog(@"<WARNING> UserHistoryEntry.comparableString How comes the streamId is empty!");
    } else {
        toReturn = [NSMutableString stringWithString:self.streamId];
    }
    [toReturn appendFormat:@" %ld", (long)self.dataType];
    [toReturn appendString:[sortedTags componentsJoinedByString:@" "]];
    if(self.measurementGroupName)
    {
        [toReturn appendFormat:@" %@",self.measurementGroupName];
    }
    if(self.measurementTypeName)
    {
        [toReturn appendFormat:@" %@",self.measurementTypeName];
    }
    return toReturn;
}

- (id)initWithEvent:(PYEvent*)event
{
    self = [super init];
    if(self)
    {
        self.streamId = event.streamId;
        self.tags = [NSArray arrayWithArray:event.tags];
        self.dataType = [event eventDataType];
        self.typeString = event.type;
        if(self.dataType == EventDataTypeValueMeasure)
        {
            NSArray *components = [event.type componentsSeparatedByString:@"/"];
            if([components count] > 1)
            {
                self.measurementGroupName = [components objectAtIndex:0];
                self.measurementTypeName = [components objectAtIndex:1];
            }
        }
    }
    return self;
}

- (PYEvent*)reconstructEvent
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = self.streamId;
    event.tags = [NSMutableArray arrayWithArray:self.tags];
    event.type = self.typeString;
#pragma warning -- this is not compatible with mutiple connection app
    event.connection = [[NotesAppController sharedInstance] connection];
    return event;
}


@end
