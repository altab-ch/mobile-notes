//
//  BaseDetailCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/23/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseDetailCell.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseDetailCell ()

@property (nonatomic, weak) IBOutlet UIView *borderView;

@end

@implementation BaseDetailCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setClipsToBounds:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.borderView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.borderView.layer.borderWidth = 0.5f;
}

- (void)setIsInEditMode:(BOOL)isInEditMode
{
    _isInEditMode = isInEditMode;
    [_borderView.layer setBorderColor:_isInEditMode ?[UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1].CGColor:[UIColor lightGrayColor].CGColor];
    _borderView.layer.borderWidth = _isInEditMode ? 1.5:0.5;
}

@end
