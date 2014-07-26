//
//  UIStoryboard+Main.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 3/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "UIStoryboard+Main.h"

@implementation UIStoryboard (Main)

+ (UIStoryboard*)mainStoryBoard
{
    return [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
}

+ (UIStoryboard*)detailsStoryBoard
{
    return [UIStoryboard storyboardWithName:@"DetailsStoryboard_iPhone" bundle:nil];
}

+ (id)instantiateViewControllerWithIdentifier:(NSString *)identifier
{
    return [[UIStoryboard mainStoryBoard] instantiateViewControllerWithIdentifier:identifier];
}

@end
