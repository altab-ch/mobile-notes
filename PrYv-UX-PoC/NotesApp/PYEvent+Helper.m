//
//  PYEvent+Helper.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"
#import <PryvApiKit/PYEventTypes.h>
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYStream.h>
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYCachingController+Event.h>
#import "CellStyleModel.h"

@implementation PYEvent (Helper)

- (NSString*)eventBreadcrumbs
{
    NSString* breadCrumb = [self.stream breadcrumbs];
    return breadCrumb;
}

/*-(EventDataType)eventDataType
{
    if ([self.type isEqualToString:@"note/txt"]) return EventDataTypeNote;
    else if ([self.type isEqualToString:@"picture/attached"]) return EventDataTypeImage;
    else return EventDataTypeValueMeasure;
}*/

- (EventDataType)eventDataType
{
    if ([[self pyType] isNumerical]) return EventDataTypeValueMeasure;
    
    if([self.pyType.classKey isEqualToString:@"note"]) return EventDataTypeNote;
    else if([self.pyType.classKey isEqualToString:@"picture"]) return EventDataTypeImage;
    
    //NSLog(@"<WARNING> Dataservice.eventDataTypeForEvent: unkown type:  %@ ", self);
    return EventDataTypeNote;
}

- (int)cellStyle
{
    
    if([self.pyType.key isEqualToString:@"note/txt"])
    {
        return CellStyleTypeText;
    }
    else if([self.pyType.classKey isEqualToString:@"money"])
    {
        return CellStyleTypeMoney;
    }
    else if([self.pyType.key isEqualToString:@"picture/attached"])
    {
        return CellStyleTypePhoto;
    }
    else if ([self.pyType isNumerical]) {
        return CellStyleTypeMeasure;
    }
   // NSLog(@"<WARNING> cellStyleForEvent: unkown type:  %@ ", self.pyType);
    return CellStyleTypeUnkown;
}

- (UIImage*)firstAttachmentFromMemoryOrCache {
    NSData* data = nil;
    if([self.attachments count] > 0) {
        PYAttachment *attachment = [self.attachments objectAtIndex:0];
        if ((attachment.fileData != nil) && attachment.fileData.length > 0) {
            data = attachment.fileData;
        } else {
        
        NSData *cachedData = [self.connection.cache dataForAttachment:attachment onEvent:self];
        if (cachedData && cachedData.length > 0) {
            data = cachedData;
        }
        }
    }
    if (data) {
        return [UIImage imageWithData:data];
    }
    return nil;
}



- (void)firstAttachmentAsImage:(void (^) (UIImage *image))attachmentAsImage
                  errorHandler:(void(^) (NSError *error))failure {
    if([self.attachments count] == 0) {
        if (failure) failure(nil);
        return;
    }
    
    [self dataForAttachment:[self.attachments objectAtIndex:0]
             successHandler:^(NSData *data) {
                 attachmentAsImage([UIImage imageWithData:data]);
             } errorHandler:failure];
    
}

- (NSString*)eventContentAsString
{
    if([self.eventContent isKindOfClass:[NSString class]])
    {
        return self.eventContent;
    }
    return [self.eventContent description];
}


@end
