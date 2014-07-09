//
//  PYEvent+Helper.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

typedef enum{
    EventDataTypeNote,
    EventDataTypeValueMeasure,
    EventDataTypeImage
} EventDataType;

@interface PYEvent (Helper)

@property (nonatomic, readonly) NSString *eventContentAsString;

- (NSString*)eventBreadcrumbs;


- (EventDataType)eventDataType;
- (int)cellStyle;

- (void)firstAttachmentAsImage:(void (^) (UIImage *image))attachmentAsImage
             errorHandler:(void(^) (NSError *error))failure;

- (UIImage*)firstAttachmentFromMemoryOrCache;

@end
