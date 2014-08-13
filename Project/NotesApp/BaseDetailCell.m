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
@property (nonatomic, weak) IBOutlet UILabel *header;

-(BOOL) shouldUpdateBorder;

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
    self.borderView.layer.borderColor = [UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1].CGColor;
    self.borderView.layer.borderWidth = 1;
    self.borderView.alpha = 0;
}

- (void)setIsInEditMode:(BOOL)isInEditMode
{
    _isInEditMode = isInEditMode;
    if ([self shouldUpdateBorder] && _header)
        [_header setTextColor:_isInEditMode?[UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1] : [UIColor lightGrayColor]];
        /*[UIView animateWithDuration:0.2 animations:^{
            self.borderView.alpha = _isInEditMode ? 1.0f : 0.0f;
        }];*/
    
}

-(void) updateWithEvent:(PYEvent*)event
{
    _event = event;
    if (_event.isDraft)
        [self setIsInEditMode:true];
    
}

-(CGFloat) getHeight
{
    return 44;
}

-(BOOL) shouldUpdateBorder
{
    return NO;
}

@end
