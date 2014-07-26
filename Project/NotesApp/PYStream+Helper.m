//
//  PYStream+Helper.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYStream+Helper.h"

@implementation PYStream (Helper)

- (UIColor*)getColor
{
    if ([self clientData] && [[self clientData] objectForKey:@"pryv-browser:bgColor"])
        return [self colorFromHexString:[[self clientData] objectForKey:@"pryv-browser:bgColor"]];
    if ([self parent])
        return [[self parent] getColor];
    
    return [UIColor lightGrayColor];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

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
