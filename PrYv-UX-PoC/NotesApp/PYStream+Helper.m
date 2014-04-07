//
//  PYStream+Helper.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYStream+Helper.h"

@implementation PYStream (Helper)


- (NSString*)breadcrumbs
{
    if([self parent])
    {
        NSString *breadcrumb = [self.parent breadcrumbs];
        if([breadcrumb length] > 0)
        {
            return [[breadcrumb stringByAppendingString:@"/"] stringByAppendingString:self.name];
        }
        else
        {
            return self.name;
        }
    }
    return self.name;
}

@end
