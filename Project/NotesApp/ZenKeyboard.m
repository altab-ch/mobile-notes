//
//  ZenKeyboard.m
//  ZenKeyboard
//
//  Created by Kevin Nick on 2012-11-9.
//  Copyright (c) 2012年 com.zen. All rights reserved.
//

#import "ZenKeyboard.h"

@interface ZenKeyboard()

@property (nonatomic,assign) id<UITextInput> textInputDelegate;
@property (nonatomic) BOOL isMinus;
@end;

@implementation ZenKeyboard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame]; 
    if (self) {
        _isMinus = false;
        //UIImageView *keyboardBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyboardBackgroundTextured"]];
        //UIImageView *keyboardGridLines = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyboardNumericEntryViewGridLinesTextured"]];
        //UIImageView *keyboardShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyboardTopShadow"]];
        
        //[self setBackgroundColor:[UIColor lightGrayColor]];
        //[self addSubview:keyboardBackground];
        //[self addSubview:keyboardGridLines];
        [self addSubview:[self addNumericKeyWithTitle:@"1" frame:CGRectMake(0, 1, KEYBOARD_NUMERIC_KEY_WIDTH - 3, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"2" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH - 2, 1, KEYBOARD_NUMERIC_KEY_WIDTH, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"3" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH * 2 - 1, 1, KEYBOARD_NUMERIC_KEY_WIDTH - 2, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        
        [self addSubview:[self addNumericKeyWithTitle:@"4" frame:CGRectMake(0, KEYBOARD_NUMERIC_KEY_HEIGHT + 2, KEYBOARD_NUMERIC_KEY_WIDTH - 3, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"5" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH - 2, KEYBOARD_NUMERIC_KEY_HEIGHT + 2, KEYBOARD_NUMERIC_KEY_WIDTH, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"6" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH * 2 - 1, KEYBOARD_NUMERIC_KEY_HEIGHT + 2, KEYBOARD_NUMERIC_KEY_WIDTH - 3, KEYBOARD_NUMERIC_KEY_HEIGHT)]];

        [self addSubview:[self addNumericKeyWithTitle:@"7" frame:CGRectMake(0, KEYBOARD_NUMERIC_KEY_HEIGHT * 2 + 3, KEYBOARD_NUMERIC_KEY_WIDTH - 3, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"8" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH - 2, KEYBOARD_NUMERIC_KEY_HEIGHT * 2 + 3, KEYBOARD_NUMERIC_KEY_WIDTH , KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"9" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH * 2 - 1, KEYBOARD_NUMERIC_KEY_HEIGHT * 2 + 3, KEYBOARD_NUMERIC_KEY_WIDTH, KEYBOARD_NUMERIC_KEY_HEIGHT)]];

        [self addSubview:[self addNumericKeyWithTitle:@"-" frame:CGRectMake(0, KEYBOARD_NUMERIC_KEY_HEIGHT * 3 + 4, KEYBOARD_NUMERIC_KEY_WIDTH - 3, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"0" frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH - 2, KEYBOARD_NUMERIC_KEY_HEIGHT * 3 + 4, KEYBOARD_NUMERIC_KEY_WIDTH , KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        [self addSubview:[self addNumericKeyWithTitle:@"." frame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH * 2 - 1, KEYBOARD_NUMERIC_KEY_HEIGHT * 3 + 4, KEYBOARD_NUMERIC_KEY_WIDTH, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        //[self addSubview:[self addBackspaceKeyWithFrame:CGRectMake(KEYBOARD_NUMERIC_KEY_WIDTH2 * 3, KEYBOARD_NUMERIC_KEY_HEIGHT * 3 + 4, KEYBOARD_NUMERIC_KEY_WIDTH2, KEYBOARD_NUMERIC_KEY_HEIGHT)]];
        
        //[self addSubview:keyboardShadow];
    }
    
    return self;
}

- (UIButton *)addNumericKeyWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:28.0]];
    
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    //[button setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //[button setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    //[button.titleLabel setShadowOffset:CGSizeMake(0, -0.5)];
    
    if (!([title isEqualToString:@"."] || [title isEqualToString:@"-"])) [button setBackgroundColor:[UIColor whiteColor]];
    else
    {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[UIColor grayColor]];
    }
    UIImage *buttonImage = [UIImage imageNamed:@"KeyboardNumericEntryKeyTextured"];
    UIImage *buttonPressedImage = [UIImage imageNamed:@"KeyboardNumericEntryKeyPressedTextured"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(pressNumericKey:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIButton *)addBackspaceKeyWithFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor grayColor]];
    button.frame = frame;
    UIImage *buttonImage = [UIImage imageNamed:@"KeyboardNumericEntryKeyTextured"];
    UIImage *buttonPressedImage = [UIImage imageNamed:@"KeyboardNumericEntryKeyPressedTextured"];
    UIImage *image = [UIImage imageNamed:@"KeyboardNumericEntryKeyBackspaceGlyphTextured"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:button.bounds];
    imgView.image = image;
    [imgView setContentMode:UIViewContentModeCenter];
    
    [button addSubview:imgView];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(pressBackspaceKey) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
    _textField.inputView = self;
    self.textInputDelegate = _textField;
    
}

- (void)pressNumericKey:(UIButton *)button {
    NSString *keyText = button.titleLabel.text;
    int key = -1;
    
    if ([@"." isEqualToString:keyText]) {
        key = 10;
    }else if([@"-" isEqualToString:keyText]){
        key = 11;
    } else {
        key = [keyText intValue];
    }
        
    NSRange dot = [_textField.text rangeOfString:@"."];
    
    switch (key) {
        case 10:
            if (dot.location == NSNotFound && _textField.text.length == 0) {                
                [self.textInputDelegate insertText:@"0."];
            } else if (dot.location == NSNotFound) {
                [self.textInputDelegate insertText:@"."];
            }
            
            break;
        case 11:
        {
            if ([_textField.text length] != 0){
                if([[_textField.text substringToIndex:1] isEqualToString:@"-"])
                    _isMinus = true;
                else
                    _isMinus = false;
            }
            
            if ([_textField.text length] == 0) {
                [_textField setText:@"-"];
                _isMinus=true;
            }else{
                if (_isMinus)
                    [_textField setText:[_textField.text substringFromIndex:1]];
                else
                    [_textField setText:[NSString stringWithFormat:@"-%@", _textField.text]];
                
                _isMinus = !_isMinus;
            }
            
        }
            break;
        default:
            /*if (kMaxNumber <= [[NSString stringWithFormat:@"%@%d", _textField.text, key] doubleValue]) {
                _textField.text = [NSString stringWithFormat:@"%d", kMaxNumber];
            } else */if ([@"0.00" isEqualToString:_textField.text]) {
                _textField.text = [NSString stringWithFormat:@"%d", key];
            } else if (dot.location == NSNotFound || _textField.text.length <= dot.location + 6) {
                [self.textInputDelegate insertText:[NSString stringWithFormat:@"%d", key]];
            }
            
            break;
    }
}

- (void)pressBackspaceKey {
    if ([@"0." isEqualToString:_textField.text]) {
        _textField.text = @"";
        
        return;
    } else {
        UITextRange *selRange = _textField.selectedTextRange;
        UITextPosition *selStartPos = selRange.start;
        NSInteger idx = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:selStartPos];
        if (idx==1 && _isMinus) {
            _isMinus=false;
        }
        [self.textInputDelegate deleteBackward];
    }
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
