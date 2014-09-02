//
//  main.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UI7Kit/UI7Kit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        /*[UI7ViewController patchIfNeeded];
        [UI7View patchIfNeeded];
        [UI7NavigationController patchIfNeeded];
        [UI7NavigationItem patchIfNeeded];
        [UI7NavigationBar patchIfNeeded];
        [UI7TableView patchIfNeeded];
        [UI7TableViewCell patchIfNeeded];
        [UI7BarButtonItem patchIfNeeded];
        [UI7Button patchIfNeeded];
        [UI7AlertView patchIfNeeded];
        [UI7ActionSheet patchIfNeeded];
        [UI7Switch patchIfNeeded];
        */
        
        [UI7Kit patchIfNeeded];
        //[[UI7Kit kit] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:169.0f/255.0f blue:215.0f/255.0f alpha:1]];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }

}
