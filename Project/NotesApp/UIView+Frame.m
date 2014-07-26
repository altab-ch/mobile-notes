//
//  UIView+Frame.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 3/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setPosition:(CGPoint)position {
    CGRect frame = self.frame;
    frame.origin = position;
    self.frame = frame;
}

- (void)moveHorizontalBy:(CGFloat)x {
    [self moveBy:CGPointMake(x, 0)];
}

- (void)moveVerticalBy:(CGFloat)y {
    [self moveBy:CGPointMake(0, y)];
}

- (void)moveBy:(CGPoint)translation {
    CGRect frame = self.frame;
    frame.origin = CGPointMake(frame.origin.x+translation.x, frame.origin.y+translation.y);
    self.frame = frame;
}

@end
