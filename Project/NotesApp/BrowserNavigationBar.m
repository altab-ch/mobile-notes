//
//  BrowserNavigationBar.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowserNavigationBar.h"

@implementation BrowserNavigationBar

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBrowserShouldScrollToTop object:nil];
}


@end
