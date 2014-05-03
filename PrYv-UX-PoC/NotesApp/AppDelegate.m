//
//  AppDelegate.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "ViewController.h"
#import "NotesAppController.h"
#import "MeasurementController.h"
#import "TestFlight.h"
#import "AppConstantsPrivate.h"
#import "MMDrawerController.h"


NSString *const kEventAddedNotification = @"kEventAddedNotification";

@interface AppDelegate ()

- (void)setupUI;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NotesAppController sharedInstance];
    [MeasurementController sharedInstance];
    [self setupUI];
    
    UINavigationController * leftDrawer = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"menu_nav_id"];
    UINavigationController * center = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"main_nav_c"];
    
    MMDrawerController* drawerController = (MMDrawerController *)self.window.rootViewController;
    [drawerController setMaximumLeftDrawerWidth:260.0];
    [drawerController setCenterViewController:center];
    [drawerController setLeftDrawerViewController:leftDrawer];
    
    // testFlight
  //  NSString *deviceToken = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
    //[TestFlight setDeviceIdentifier:deviceToken];
    [TestFlight setOptions:@{ TFOptionDisableInAppUpdates : @YES }];
    [TestFlight takeOff:kPYAppConstantsPrivateTestFlightToken];
    TFLog(@"appStarted");
    return YES;
}

- (void)setupUI {
    
    //UINavigationBar
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    if(![UIDevice isiOS7Device])
    {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                UITextAttributeTextColor: [UIColor blackColor],
                          UITextAttributeTextShadowColor: [UIColor clearColor],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                     UITextAttributeFont: [UIFont fontWithName:@"Museo-300" size:20.0]
     }];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
