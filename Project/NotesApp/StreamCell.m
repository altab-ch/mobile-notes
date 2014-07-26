//
//  StreamCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "StreamCell.h"

@implementation StreamCell

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

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
    [self addGestureRecognizer:tapGR];
}

- (void)cellTapped:(UITapGestureRecognizer *)tapGR
{
    CGPoint point = [tapGR locationInView:self];
    if(self.accessoryImageView.image == nil)
    {
        [self realCellTapped];
    }
    else
    {
        if(CGRectContainsPoint(self.accessoryImageView.frame, point))
        {
            [self accessoryImageTapped];
        }
        else
        {
            [self realCellTapped];
        }
    }
}

- (void)accessoryImageTapped
{
    if(self.streamAccessoryTappedHandler)
    {
        self.streamAccessoryTappedHandler(self,self.index);
    }
}

- (void)realCellTapped
{
    if(self.streamCellTappedHandler)
    {
        self.streamCellTappedHandler(self,self.index);
    }
}

@end
