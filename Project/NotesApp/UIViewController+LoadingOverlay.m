//
//  UIViewController+LoadingOverlay.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/1/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIViewController+LoadingOverlay.h"
#import "MBProgressHUD.h"

@implementation UIViewController (LoadingOverlay)

- (void)showLoadingOverlay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.view.userInteractionEnabled = NO;
    });
}


- (void)hideLoadingOverlay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
    });
}

@end
