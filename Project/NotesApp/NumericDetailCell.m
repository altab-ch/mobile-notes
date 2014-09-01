//
//  NumericDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NumericDetailCell.h"
#import "PYEvent+Helper.h"
#import "ZenKeyboard.h"

@interface NumericDetailCell () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *numericalValue_Label;
@property (nonatomic, weak) IBOutlet UILabel *numericalValue_TypeLabel;
@property (nonatomic, weak) IBOutlet UITextField *numericalValue;
@property (nonatomic, weak) IBOutlet UIButton *backspace;

@end

@implementation NumericDetailCell

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
    
    [self.numericalValue_TypeLabel setText:[event.pyType localizedName]];
    [self.numericalValue_Label setText:[event.pyType symbol]];
    [self.numericalValue setText:[self getNumericalValueFormatted:event]];
    
    ZenKeyboard *keyboard = [[ZenKeyboard alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
    [keyboard setTextField:self.numericalValue];
}

-(NSString*) getNumericalValueFormatted:(PYEvent*)event
{
    NSString *value = NULL;
    if ([event.eventContent isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *numf = [[NSNumberFormatter alloc] init];
        [numf setNumberStyle:NSNumberFormatterDecimalStyle];
        if ([[numf stringFromNumber:event.eventContent] rangeOfString:@"."].length != 0){
            [numf setMinimumFractionDigits:2];
        }else{
            [numf setMaximumFractionDigits:0];
        }
        
        value = [numf stringFromNumber:event.eventContent];
    }else{
        value = event.eventContentAsString;
    }
    return value;
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [self.numericalValue setEnabled:isInEditMode];
    if (self.event.isDraft && isInEditMode) [self.numericalValue becomeFirstResponder];
    else [self.numericalValue resignFirstResponder];
    [self.backspace setHidden:YES];
}

-(void) didSelectCell:(UIViewController*)controller
{
    [self.numericalValue becomeFirstResponder];
}

-(IBAction)valueTextFieldDidChange:(id)sender
{
    [self.delegate detailShouldUpdateEvent];
    self.event.eventContent = self.numericalValue.text;
}

#pragma mark - UITextFieldDelegate

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate closePickers:NO];
    [self.backspace setHidden:NO];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [self.backspace setHidden:YES];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    return 90;
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
