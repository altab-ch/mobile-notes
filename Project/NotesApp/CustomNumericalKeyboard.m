//
//  CustomNumericalKeyboard.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "CustomNumericalKeyboard.h"

@interface CustomNumericalKeyboard ()

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic) BOOL isMinus;

- (IBAction)clicked:(UIButton *)sender;

@end

@implementation CustomNumericalKeyboard

- (UITextField*)textField
{
    if(!_textField)
    {
        _textField = [_delegate textFieldForCustomkeyboard:self];
    }
    return _textField;
}

- (void)clicked:(UIButton *)sender
{
    NSRange dot = [self.textField.text rangeOfString:@"."];
    
    switch (sender.tag)
    {
        case 10:
            if (dot.location == NSNotFound) {
                self.textField.text = [NSString stringWithFormat:@"%@%@",self.textField.text,@"."];
            }
            break;
        case 11:
            if(self.textField.text.length > 0)
            {
                self.textField.text = [self.textField.text substringToIndex:self.textField.text.length - 1];
            }
            break;
        case 12:
            if(self.textField.text.length > 0)
            {
                if (_isMinus) {
                    _isMinus=false;
                    [self.textField setText:[self.textField.text substringFromIndex:1]];
                }else{
                    _isMinus=true;
                    [self.textField setText:[NSString stringWithFormat:@"-%@",self.textField.text]];
                }
            }
            break;
        default:
            if (dot.location == NSNotFound || self.textField.text.length <= dot.location + 8) {
                self.textField.text = [NSString stringWithFormat:@"%@%d",self.textField.text,sender.tag];
            }
            break;
    }
    [_delegate textFieldValueChangedForCustomNumericalKeyboard:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
