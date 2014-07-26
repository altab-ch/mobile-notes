//
//  ConditionallyAnimatedPushSegue.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 2/3/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "ConditionallyAnimatedPushSegue.h"
#import "EventDetailsViewController.h"

@implementation ConditionallyAnimatedPushSegue

- (void)perform
{
    EventDetailsViewController *sourceVC = [self sourceViewController];
    UIViewController *destVC = [self destinationViewController];
    BOOL animated = [sourceVC shouldAnimateViewController:destVC];
    [[sourceVC navigationController] pushViewController:destVC animated:animated];
}

@end
