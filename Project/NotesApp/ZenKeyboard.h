//
//  ZenKeyboard.h
//  ZenKeyboard
//
//  Created by Kevin Nick on 2012-11-9.
//  Copyright (c) 2012年 com.zen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEYBOARD_NUMERIC_KEY_WIDTH 108
#define KEYBOARD_NUMERIC_KEY_HEIGHT 53
#define KEYBOARD_NUMERIC_KEY_WIDTH2 80

@protocol ZenKeyboardDelegate <NSObject>

- (void)numericKeyDidPressed:(int)key;
- (void)backspaceKeyDidPressed;

@end

@interface ZenKeyboard : UIView

- (void)pressBackspaceKey;

@property (nonatomic, assign) UITextField *textField;

@end
