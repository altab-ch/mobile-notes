//
//  DescriptionDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DescriptionDetailCell.h"

@interface DescriptionDetailCell () <UITextViewDelegate>

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
    self.descriptionText.delegate = self;
    _descriptionText.text = self.event.eventDescription;
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [_descriptionText setEditable:isInEditMode];
    [self.descriptionText resignFirstResponder];
}

-(void) didSelectCell:(UIViewController *)controller
{
    [self.descriptionText becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.delegate closePickers];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    return self.isInEditMode;
}

- (void) textViewDidChange:(UITextView *)textView
{
    [self.delegate detailShouldUpdateEvent];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.event.eventDescription = self.descriptionText.text;
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    if([self.descriptionText.text length] == 0)
        return 74;

    if ([self.descriptionText.text length] > 0)
        return [self heightForNoteTextViewWithString:self.descriptionText.text];
    
    return 0;
}

-(CGFloat) heightForNoteTextViewWithString:(NSString*)s
{
    NSDictionary *attributes = @{NSFontAttributeName: self.descriptionText.font};
    CGRect rect = [s boundingRectWithSize:CGSizeMake(self.descriptionText.frame.size.width-10, CGFLOAT_MAX)
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
