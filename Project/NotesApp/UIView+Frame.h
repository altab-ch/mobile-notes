//
//  UIView+Frame.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 3/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setSize:(CGSize)size;
- (void)setPosition:(CGPoint)position;
- (void)moveHorizontalBy:(CGFloat)x;
- (void)moveVerticalBy:(CGFloat)y;
- (void)moveBy:(CGPoint)translation;

@end
