//
//  UIImage+PrYv.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/22/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIImage+PrYv.h"

@implementation UIImage (PrYv)

- (UIImage*)imageScaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
