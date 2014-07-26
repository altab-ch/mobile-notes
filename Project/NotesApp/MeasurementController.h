//
//  MeasurementController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/27/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeasurementController : NSObject

+ (MeasurementController*)sharedInstance;

- (void)addMeasurementSetWithKey:(NSString*)key;
- (void)removeMeasurementSetWithKey:(NSString*)key;
- (NSArray*)userSelectedMeasurementSets;

@end
