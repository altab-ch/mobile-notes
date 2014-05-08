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
#import "CellStyleModel.h"

@implementation PYEvent (Helper)

- (NSString*)eventBreadcrumbs
{
    NSString* breadCrumb = [self.stream breadcrumbs];
    return breadCrumb;
}



- (EventDataType)eventDataType
{
    if ([[self pyType] isNumerical]) {
        return EventDataTypeValueMeasure;
    }
    
    NSString *eventClassKey = self.pyType.classKey;
    if([eventClassKey isEqualToString:@"note"])
    {
        return EventDataTypeNote;
    }
    else if([eventClassKey isEqualToString:@"picture"])
    {
        return EventDataTypeImage;
    }
    //NSLog(@"<WARNING> Dataservice.eventDataTypeForEvent: unkown type:  %@ ", self);
    return EventDataTypeNote;
}

- (NSInteger)cellStyle
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

- (BOOL)hasFirstAttachmentFileDataInMemory {
    if([self.attachments count] > 0) {
        PYAttachment *attachment = [self.attachments objectAtIndex:0];
        return ((attachment.fileData != nil) && attachment.fileData.length > 0);
    }
    return false;
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
