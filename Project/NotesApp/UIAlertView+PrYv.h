//
//  UIAlertView+PrYv.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (PrYv)

- (void)showWithCompletionBlock:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completionBlock;

@end
