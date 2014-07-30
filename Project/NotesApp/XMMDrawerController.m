//
//  MMDrawerController.m
//  NotesApp
//
//  Created by Perki on 13.06.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "XMMDrawerController.h"

NSString *const kDrawerDidCloseNotification = @"kDrawerDidCloseNotification";

@implementation XMMDrawerController : MMDrawerController

-(void)closeDrawerAnimated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL))completion __attribute((objc_requires_super)) {
    
    [super closeDrawerAnimated:animated velocity:velocity animationOptions:options completion:^(BOOL finished) {
        if (completion) { completion(finished); }
         [[NSNotificationCenter defaultCenter] postNotificationName:kDrawerDidCloseNotification object:nil];
    }];
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
