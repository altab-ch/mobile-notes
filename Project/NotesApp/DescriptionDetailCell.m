//
//  DescriptionDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DescriptionDetailCell.h"

@interface DescriptionDetailCell ()

@property (nonatomic, weak) IBOutlet UITextView *descriptionText;

@end

@implementation DescriptionDetailCell

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
    _descriptionText.text = self.event.eventDescription;
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [_descriptionText setEditable:isInEditMode];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
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
