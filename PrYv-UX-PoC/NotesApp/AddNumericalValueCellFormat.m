//
//  AddNumericalValueViewCellClass.m
//  NotesApp
//
//  Created by Perki on 10.12.13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AddNumericalValueCellFormat.h"

@implementation AddNumericalValueCellFormat

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AddNumericalValueCellFormat" owner:self options:nil];
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
