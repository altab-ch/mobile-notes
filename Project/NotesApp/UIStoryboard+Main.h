//
//  UIStoryboard+Main.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 3/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Main)

+ (UIStoryboard*)mainStoryBoard;
+ (UIStoryboard*)detailsStoryBoard;
+ (id)instantiateViewControllerWithIdentifier:(NSString*)identifier;

@end
