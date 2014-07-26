//
//  NSString+Utils.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/18/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+ (instancetype)randomStringWithLength:(NSInteger)length
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    NSUInteger aLength = [alphabet length];
    for (NSUInteger i = 0U; i < length; i++) {
        u_int32_t r = arc4random() % aLength;
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

@end
