//
//  UIBarButtonItem+PrYv.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIBarButtonItem+PrYv.h"

@implementation UIBarButtonItem (PrYv)

+ (UIBarButtonItem*)flatBarItemWithImage:(UIImage*)image target:(id)target action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, image.size.width + 10, 44);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barItem;
}

+ (UIBarButtonItem*)flatBarItemWithImage:(UIImage *)image text:(NSString *)text target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
	[button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(1, 10, 0, 10)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, [text sizeWithFont:button.titleLabel.font].width + 20, 29);
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barItem;
}

@end
