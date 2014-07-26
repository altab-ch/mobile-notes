//
//  AddNumericalValueCellClass.m
//  NotesApp
//
//  Created by Perki on 11.12.13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AddNumericalValueCellClass.h"

@implementation AddNumericalValueCellClass


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AddNumericalValueCellClass" owner:self options:nil];
        [self addSubview: self.contentView];
        [self setBackgroundColor:[UIColor clearColor]];

    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.contentView];
}


@end
