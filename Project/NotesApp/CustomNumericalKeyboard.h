//
//  CustomNumericalKeyboard.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomNumericalKeyboard;

@protocol CustomKeyboardDelegate <NSObject>

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard*)customKeybord;
- (void)textFieldValueChangedForCustomNumericalKeyboard:(CustomNumericalKeyboard*)customKeyboard;

@end

@interface CustomNumericalKeyboard : UIView

@property (nonatomic, weak) IBOutlet id<CustomKeyboardDelegate> delegate;

@end
