//
//  StreamAccessory.m
//  NotesApp
//
//  Created by Mathieu Knecht on 30.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "StreamAccessory.h"

@interface StreamAccessory ()

@property (nonatomic, strong) UIView *pastille;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *text;

@end

@implementation StreamAccessory

- (id)initText:(NSString*)text color:(UIColor*)color
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setCornerRadius:4];
        [self setText:text];
        [self setLabel:[[UILabel alloc] init]];
        [self.label setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
        [self.label setTextColor:[UIColor grayColor]];
        CGSize lbSize = [self.text sizeWithFont:self.label.font];
        if (color) {
            [self.label setFrame:CGRectMake(18, 0, lbSize.width, 14)];
            [self setFrame:CGRectMake(10, 6, lbSize.width+22, 16)];
            [self.label setText:self.text];
            [self setPastille:[[UIView alloc] initWithFrame:CGRectMake(2, 2, 10, 11)]];
            [self.pastille.layer setCornerRadius:5];
            [self.pastille setBackgroundColor:color];
            [self addSubview:self.pastille];
        }else{
            [self.label setFrame:CGRectMake(3, 0, lbSize.width, 14)];
            [self setFrame:CGRectMake(320-(lbSize.width+15), 6, lbSize.width+6, 16)];
            [self.label setText:self.text];
        }
        
        [self addSubview:self.label];
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
