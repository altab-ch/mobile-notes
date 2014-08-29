//
//  DescriptionLabel.m
//  NotesApp
//
//  Created by Mathieu Knecht on 29.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DescriptionLabel.h"

@implementation DescriptionLabel

- (id)initWithText:(NSString*)text
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        //[self.layer setCornerRadius:4];
        [self setText:text];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
        [self setTextColor:[UIColor whiteColor]];
        CGSize lbSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(280, 18)];
        [self setFrame:CGRectMake(15, 116, lbSize.width+10, lbSize.height)];
        [self setTextAlignment:NSTextAlignmentCenter];
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

@end
