//
//  DeleteDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DeleteDetailCell.h"

@interface DeleteDetailCell ()

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation DeleteDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    /*[self.deleteButton.layer setBorderColor:[UIColor colorWithRed:189.0/255.0 green:16.0/255.0 blue:38.0/255.0 alpha:1].CGColor];
    [self.deleteButton.layer setBorderWidth:1];
    self.deleteButton.layer.cornerRadius = 5;*/
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return NO;
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
