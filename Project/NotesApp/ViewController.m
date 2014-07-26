//
//  ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ViewController.h"
#import "BrowseEventsViewController.h"
#import "DataService.h"
#import "LRUManager.h"
#import "XMMDrawerController.h"
#import "InboardingViewController.h"

#define FIRST_LAUNCH @"First_launch_date"

@interface ViewController ()

@property (nonatomic, strong) BrowseEventsViewController *browseEventsVC;
@property (nonatomic, strong) UIViewController* pyLoginViewController;
@property (nonatomic) BOOL launched;
@property (nonatomic, strong) XMMDrawerController *drawerController;

- (void)closeLoginWebView:(BOOL)reopen;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userShouldLoginNotification:)
                                                 name:kUserShouldLoginNotification
                                               object:nil];
    self.launched = false;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.launched) {
        self.launched = true;
        [self initSignIn];
    }
    
    
}

#pragma mark - Sign In

- (void)initSignIn
{
    if(![[NotesAppController sharedInstance] connection])
    {
        NSArray *permissions = @[ @{ kPYAPIConnectionRequestStreamId : kPYAPIConnectionRequestAllStreams ,
                                   kPYAPIConnectionRequestLevel: kPYAPIConnectionRequestManageLevel}
                                  
                                  
                                  ];
        
        [PYWebLoginViewController requestConnectionWithAppId:@"pryv-ios-app"
                                              andPermissions:permissions
                                                 andBarStyle:BarStyleTypeHome
                                                    delegate:self];
    }
    else
    {
        [self launchDrawer];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveAccessTokenNotification object:nil];
    }
}

#pragma mark - Init XMM_DRAWER

-(void) initDrawer
{
    
    UINavigationController * leftDrawer = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"menu_nav_id"];
    UINavigationController * center = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"main_nav_c"];
    
    self.drawerController = [[XMMDrawerController alloc] initWithCenterViewController:center leftDrawerViewController:leftDrawer];
    [self.drawerController setMaximumLeftDrawerWidth:260.0];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView | MMCloseDrawerGestureModeTapCenterView];
    
}

-(void) launchDrawer
{
    if (self.pyLoginViewController) {
        [self.pyLoginViewController dismissViewControllerAnimated:YES completion:^{
            [self initDrawer];
            [self presentViewController:self.drawerController animated:YES completion:nil];
        }];
        self.pyLoginViewController = nil;
    }else{
        [self initDrawer];
        [self presentViewController:self.drawerController animated:YES completion:nil];
    }
}

#pragma mark - PYWebLoginDelegate


- (void)closeLoginWebView:(BOOL)reopen;
{
    if (self.pyLoginViewController) {
        [self.pyLoginViewController dismissViewControllerAnimated:YES completion:^{
            if (reopen) {
                [self initSignIn];
            }
        
        }];
        self.pyLoginViewController = nil;
    }
}

- (UIViewController*)pyWebLoginGetController
{
    return nil;
}

- (BOOL)pyWebLoginShowUIViewController:(UIViewController*)loginViewController
{
    
    
    if (self.drawerController)
        [self.drawerController dismissViewControllerAnimated:YES completion:^{
            self.drawerController = nil;
            self.pyLoginViewController = loginViewController;
            [self presentViewController:loginViewController animated:YES completion:nil];
        }];
    else{
        self.pyLoginViewController = loginViewController;
        [self presentViewController:loginViewController animated:YES completion:^{[self displayTutorial];}];
    }
    
    return YES;
}

-(void)displayTutorial
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:FIRST_LAUNCH]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:FIRST_LAUNCH];
        InboardingViewController *tuto = [InboardingViewController sharedInstance];
        [(UINavigationController*)_pyLoginViewController pushViewController:tuto animated:YES];
    }
}

- (void)pyWebLoginSuccess:(PYConnection *)pyConnection
{
    [[NotesAppController sharedInstance] setConnection:pyConnection];
    [self initSignIn];
}

- (void)pyWebLoginAborted:(NSString*)reason
{
    [self.browseEventsVC hideLoadingOverlay];
    NSLog(@"Login aborted with reason: %@",reason);
    [self closeLoginWebView:YES];
    
}

- (void)pyWebLoginError:(NSError *)error
{
    NSLog(@"Login error: %@",error);
    [self closeLoginWebView:YES];
}

#pragma mark - Notifications

- (void)userShouldLoginNotification:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
    [self initSignIn];
}


@end
