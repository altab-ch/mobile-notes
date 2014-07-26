//
//  UIBarButtonItem+PrYv.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (PrYv)

+ (UIBarButtonItem*)flatBarItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)flatBarItemWithImage:(UIImage*)image text:(NSString*)text target:(id)target action:(SEL)action;

@end
