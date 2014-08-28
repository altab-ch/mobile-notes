//
//  NoteDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NoteDetailCell.h"
#import "PYEvent+Helper.h"

@interface NoteDetailCell () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *noteText;
@end

@implementation NoteDetailCell

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    self.noteText.delegate = self;
    self.noteText.text = event.eventContentAsString;
    [self setFrame:CGRectMake(0, 0, 320, [self getHeight])];
    [self layoutIfNeeded];
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [self.noteText setEditable:isInEditMode];
    if (self.event.isDraft && isInEditMode) [self.noteText becomeFirstResponder];
    else [self.noteText resignFirstResponder];
}

-(void) didSelectCell:(UIViewController*)controller
{
    [self.noteText becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.delegate closePickers:true];
    return self.isInEditMode;
}

- (void) textViewDidChange:(UITextView *)textView
{
    [self.delegate detailShouldUpdateEvent];
    [self setFrame:CGRectMake(0, 0, 320, [self getHeight])];
    [self layoutIfNeeded];
    [self.eventDelegate updateTableview];
    self.event.eventContent = self.noteText.text;
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    if([self.noteText.text length] == 0) {
        return 74;
    }
    if ([self.noteText.text length] > 0)
    {
        return [self heightForNoteTextViewWithString:self.noteText.text];
    }
    return 44;
}

-(CGFloat) heightForNoteTextViewWithString:(NSString*)s
{
    NSDictionary *attributes = @{NSFontAttributeName: self.noteText.font};
    CGRect rect = [s boundingRectWithSize:CGSizeMake(self.noteText.frame.size.width-10, CGFLOAT_MAX)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:attributes
                                  context:nil];
    if ([s characterAtIndex:s.length-1]=='\n')
        rect.size.height += 20;
    
    return rect.size.height+56 ;
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
