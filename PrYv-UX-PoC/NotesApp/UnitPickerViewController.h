//
//  UnitPickerViewController.h
//  NotesApp
//
//  Created by Mathieu Knecht on 10.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PYEvent;

@protocol UnitPickerDelegate <NSObject>

- (void)unitPickerController:(UIImagePickerController *)picker didFinishPickingUnit:(PYEvent*)event;

@end

@interface UnitPickerViewController : UIViewController

@property (nonatomic, weak) id<UnitPickerDelegate> delegate;
@property (nonatomic, strong) PYEvent* event;

@end
