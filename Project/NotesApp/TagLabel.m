//
//  TagLabel.m
//  NotesApp
//
//  Created by Mathieu Knecht on 27.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "TagLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation TagLabel

-(id) initWithText:(NSString*)text
{
    self = [super init];
    if (self) {
        self.text = text;
        self.textColor = [UIColor whiteColor];
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor colorWithRed:23.0/255.0 green:150/255.0 blue:193/255.0 alpha:1].CGColor;
        self.layer.cornerRadius = 4;
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        CGSize labelSize = [self.text sizeWithFont:self.font];
        self.frame = CGRectMake(0, 0, labelSize.width+6, 18);
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:0.8].CGColor;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0.f, 0.f, 2.f, 0.f))];
}

@end
