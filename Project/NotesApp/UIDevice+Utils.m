//
//  UIDevice+Utils.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIDevice+Utils.h"

@implementation UIDevice (Utils)

+ (BOOL)isiOS7Device
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0);
}

@end
