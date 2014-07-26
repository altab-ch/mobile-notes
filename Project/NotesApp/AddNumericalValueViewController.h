//
//  AddNumericalValueViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNumericalKeyboard.h"

@interface AddNumericalValueViewController : BaseViewController <CustomKeyboardDelegate>

@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) NSString *valueClass;
@property (nonatomic, strong) NSString *valueType;
@property (nonatomic, strong) NSString *value;

@property (copy) void (^valueDidChangeBlock)(NSString* valueClass, NSString *valueType, NSString* value, AddNumericalValueViewController *addNumericalVC);

- (void)setupCustomCancelButton;

@end
