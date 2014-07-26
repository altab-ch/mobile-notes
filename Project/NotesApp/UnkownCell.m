//
//  UnkownCell.m
//  NotesApp
//
//  Created by Perki on 12.12.13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UnkownCell.h"

@implementation UnkownCell

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)updateWithEvent:(PYEvent *)event
{
    [self.contentLabel setText:[event.eventContent descriptionInStringsFileFormat]];
    [self.typeLabel setText:event.type];
    [super updateWithEvent:event];
}


@end
