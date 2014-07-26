//
//  UIAlertView+PrYv.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIAlertView+PrYv.h"
#import <objc/runtime.h>

@interface PrYvAlertWrapper : NSObject

@property (copy) void(^completionBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@end

@implementation PrYvAlertWrapper

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock)
    {
        self.completionBlock(alertView, buttonIndex);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.completionBlock)
    {
        self.completionBlock(alertView, alertView.cancelButtonIndex);
    }
}

@end

static const char kPrYvAlertWrapper;

@implementation UIAlertView (PrYv)

#pragma mark - Class Public

- (void)showWithCompletionBlock:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completionBlock
{
    PrYvAlertWrapper *alertWrapper = [[PrYvAlertWrapper alloc] init];
    alertWrapper.completionBlock = completionBlock;
    self.delegate = alertWrapper;
    objc_setAssociatedObject(self, &kPrYvAlertWrapper, alertWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self show];
}

@end
