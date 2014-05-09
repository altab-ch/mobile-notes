//
//  MenuNavController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 02.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "MenuNavController.h"
#import "MenuTableViewController.h"

@interface MenuNavController ()

@end

@implementation MenuNavController

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
    // Do any additional setup after loading the view.
}

-(void) resetMenu{
    [self popToRootViewControllerAnimated:YES];
    MenuTableViewController* child = (MenuTableViewController*)[self topViewController];
    [child resetMenu];
}

-(NSArray*) getMenuStreams
{
    MenuTableViewController* child = (MenuTableViewController*)[self topViewController];
    return [child getStreamIDs];
}

- (NSDate*) getDate
{
    MenuTableViewController* child = (MenuTableViewController*)[self topViewController];
    return [child getDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
