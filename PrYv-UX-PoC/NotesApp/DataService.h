//
//  DataService.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PYEvent;

@interface DataService : NSObject

+ (DataService*)sharedInstance;

- (void)saveEventAsShortcut:(PYEvent*)event andShouldTakePictureFlag:(BOOL)shouldTakePictureFlag;

@end
