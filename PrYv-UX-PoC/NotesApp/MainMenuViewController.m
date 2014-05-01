//
//  MainMenuViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SettingsViewController.h"
#import "MMDrawerController.h"

@interface MainMenuViewController ()
-(MMDrawerController*)mm_drawerController;
@end

@implementation MainMenuViewController

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

-(MMDrawerController*)mm_drawerController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[MMDrawerController class]]){
            return (MMDrawerController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

-(IBAction)btSettingsPressed:(id)sender{
    SettingsViewController *svc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController_ID"];
    [self.mm_drawerController presentViewController:svc animated:YES completion:nil];
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
