//
//  NoteDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NoteDetailCell.h"
#import "PYEvent+Helper.h"

@interface NoteDetailCell ()

@property (nonatomic, weak) IBOutlet UITextView *noteText;

@end

@implementation NoteDetailCell

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
    _noteText.text = event.eventContentAsString;
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [_noteText setEditable:isInEditMode];
    if (self.event.isDraft && isInEditMode) [_noteText becomeFirstResponder];
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
