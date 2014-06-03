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

@interface ViewController ()

@property (nonatomic, strong) BrowseEventsViewController *browseEventsVC;
@property (nonatomic, strong) UIViewController* pyLoginViewController;

- (void)userDidLogoutNotification:(NSNotification*)notification;
- (void)closeLoginWebView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogoutNotification:)
                                                 name:kUserDidLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userShouldLoginNotification:)
                                                 name:kUserShouldLoginNotification
                                               object:nil];
    
    self.browseEventsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"BrowseEventsViewController_ID"];
    [self.navigationController pushViewController:self.browseEventsVC animated:NO];
    [self initSignIn];
}

#pragma mark - Sign In

- (void)initSignIn
{
    if(![[NotesAppController sharedInstance] connection])
    {
        
        NSArray *keys = [NSArray arrayWithObjects:  kPYAPIConnectionRequestStreamId,
                         kPYAPIConnectionRequestLevel,
                         nil];
        
        NSArray *objects = [NSArray arrayWithObjects:   kPYAPIConnectionRequestAllStreams,
                            kPYAPIConnectionRequestManageLevel,
                            nil];
        
        NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects
                                                                                    forKeys:keys]];
        
        [PYWebLoginViewController requestConnectionWithAppId:@"pryv-ios-app"
                                              andPermissions:permissions
                                                 andBarStyle:BarStyleTypeHome
                                                    delegate:self];
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveAccessTokenNotification object:nil];
    }
}

#pragma mark - PYWebLoginDelegate


- (void)closeLoginWebView
{
    if (self.pyLoginViewController) {
        [self.pyLoginViewController dismissViewControllerAnimated:YES completion:^{ }];
        self.pyLoginViewController = nil;
    }
}

- (UIViewController*)pyWebLoginGetController
{
    return nil;
}

- (BOOL)pyWebLoginShowUIViewController:(UIViewController*)loginViewController
{
    self.pyLoginViewController = loginViewController;
    [self.browseEventsVC presentViewController:loginViewController animated:YES completion:nil];
    return YES;
}

- (void)pyWebLoginSuccess:(PYConnection *)pyConnection
{
    [pyConnection synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
    //self.browseEventsVC.enabled = YES;
    [self.browseEventsVC.view setHidden:NO];
    [[NotesAppController sharedInstance] setConnection:pyConnection];
    [self closeLoginWebView];
}

- (void)pyWebLoginAborted:(NSString*)reason
{
    //self.browseEventsVC.enabled = NO;
    [self.browseEventsVC hideLoadingOverlay];
    NSLog(@"Login aborted with reason: %@",reason);
    [self closeLoginWebView];
    
}

- (void)pyWebLoginError:(NSError *)error
{
    NSLog(@"Login error: %@",error);
    [self closeLoginWebView];
}

#pragma mark - Notifications

- (void)userDidLogoutNotification:(NSNotification *)notification
{
    //self.browseEventsVC.enabled = NO;
    [self.browseEventsVC clearCurrentData];
    [[LRUManager sharedInstance] clearAllLRUEntries];
    
    /*[self.browseEventsVC dismissViewControllerAnimated:YES completion:^{
     [self initSignIn];
     }];*/
    [self.browseEventsVC.view setHidden:YES];
    
}

- (void)userShouldLoginNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initSignIn];
    });
}


@end
