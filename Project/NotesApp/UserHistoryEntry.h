//
//  UserHistoryEntry.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PryvApiKit/PryvApiKit.h>

@interface UserHistoryEntry : NSObject <NSCoding>

@property (nonatomic, strong) NSString *streamId;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic) NSInteger dataType;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, strong) NSString *measurementGroupName;
@property (nonatomic, strong) NSString *measurementTypeName;

- (NSString*)comparableString;

- (id)initWithEvent:(PYEvent*)event;
- (PYEvent*)reconstructEvent;

@end
