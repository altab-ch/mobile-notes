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
    MenuTableViewController* child = (MenuTableViewController*)[self getTableViewController];
    [child resetMenu];
}

-(void) initStreams
{
    MenuTableViewController* child = (MenuTableViewController*)[self getTableViewController];
    [child initStreams];
}

-(NSArray*) getMenuStreams
{
    MenuTableViewController* child = (MenuTableViewController*)[self getTableViewController];
    if (child.getStreamIDs.count == 0) return nil;
    return [child getStreamIDs];
}

- (NSDate*) getDate
{
    MenuTableViewController* child = (MenuTableViewController*)[self getTableViewController];
    return [child getDate];
}

- (void) reload
{
    MenuTableViewController* child = (MenuTableViewController*)[self getTableViewController];
    [child reload];
}

- (void) addStream:(NSString*)streamName
{
    //MenuTableViewController* child = (MenuTableViewController*)[self topViewController];
    //[child addStream:streamName];
}

-(MenuTableViewController*)getTableViewController
{
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[MenuTableViewController class]]) {
            return (MenuTableViewController*)vc;
        }
    }
    return nil;
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
