//
//  BaseViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/8/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*NSString *imgName = imageNameForCurrentDevice(@"app_bg");
	UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    [self.view insertSubview:background atIndex:0];
    self.navigationController.navigationBar.layer.masksToBounds = NO;*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popVC:(id)sender
{
    [self popViewController];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
