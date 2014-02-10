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

- (NSString*)eventBreadcrumbsForStreamsList:(NSArray *)streams
{
    NSString *streamId = self.streamId;
    if(streamId)
    {
        for(PYStream* stream in streams)
        {
            if([stream.streamId isEqualToString:streamId])
            {
                return [stream breadcrumbsInStreamList:streams];
            }
        }
    }
    return nil;
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
    NSLog(@"<WARNING> Dataservice.eventDataTypeForEvent: unkown type:  %@ ", self);
    return EventDataTypeNote;
}

- (NSInteger)cellStyle
{
    
    NSString *eventClassKey = self.pyType.classKey;
    if([eventClassKey isEqualToString:@"note"])
    {
        return CellStyleTypeText;
    }
    else if([eventClassKey isEqualToString:@"money"])
    {
        return CellStyleTypeMoney;
    }
    else if([eventClassKey isEqualToString:@"picture"])
    {
        return CellStyleTypePhoto;
    }
    else if ([self.pyType isNumerical]) {
        return CellStyleTypeMeasure;
    }
    //NSLog(@"<WARNING> cellStyleForEvent: unkown type:  %@ ", event);
    return CellStyleTypeUnkown;
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


@end
