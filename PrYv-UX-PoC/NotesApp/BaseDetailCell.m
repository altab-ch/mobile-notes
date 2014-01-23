//
//  BaseDetailCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/23/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseDetailCell.h"

@interface BaseDetailCell ()

@property (nonatomic, weak) IBOutlet UIView *borderView;

@end

@implementation BaseDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.borderView.layer.borderColor = [UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1].CGColor;
    self.borderView.layer.borderWidth = 2.0f;
    self.borderView.alpha = 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsInEditMode:(BOOL)isInEditMode
{
    _isInEditMode = isInEditMode;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.borderView.alpha = _isInEditMode ? 1.0f : 0.0f;
    }];
}

@end
