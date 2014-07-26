//
//  CategoryCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/1/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    UIColor *backgroundColor = nil;
    if(selected)
    {
        backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    }
    else
    {
        backgroundColor = [UIColor clearColor];
    }
    self.backgroundColor = backgroundColor;
}

@end
