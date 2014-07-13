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
    
    //self.borderView.layer.borderColor = [UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1].CGColor;
    self.borderView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.borderView.layer.borderWidth = 0.5f;
    //self.borderView.alpha = 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsInEditMode:(BOOL)isInEditMode
{
    _isInEditMode = isInEditMode;
    [_borderView.layer setBorderColor:_isInEditMode ?[UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1].CGColor:[UIColor darkGrayColor].CGColor];
    self.borderView.layer.borderWidth = _isInEditMode ?1:0.5;
    /*[UIView animateWithDuration:0.2 animations:^{
        self.borderView.alpha = _isInEditMode ? 1.0f : 0.0f;
    }];*/
}

@end
