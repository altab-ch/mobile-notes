//
//  NotesAppController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/13/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "NotesAppController.h"
#import <PryvApiKit/PryvApiKit.h>
#import "DataService.h"
#import "SSKeychain.h"
#import "SettingsController.h"

#import "TestFlight.h"

#define kServiceName @"com.pryv.notesapp"
#define kLastUsedUsernameKey @"lastUsedUsernameKey"

NSString *const kAppDidReceiveAccessTokenNotification = @"kAppDidReceiveAccessTokenNotification";
NSString *const kUserDidLogoutNotification = @"kUserDidLogoutNotification";
NSString *const kUserShouldLoginNotification = @"kUserShouldLoginNotification";
NSString *const kUserDidCreateEventNotification = @"kUserDidCreateEventNotification";
NSString *const kBrowserShouldUpdateNotification = @"kBrowserShouldUpdateNotification";
NSString *const kBrowserShouldScrollToEvent = @"kBrowserShouldScrollToEvent";

@interface NotesAppController ()

- (void)initObject;
- (void)userDidLogout;
- (void)loadSavedConnection;
- (void)saveConnection:(PYConnection*)connection;
- (void)removeConnection:(PYConnection*)connection;


@end

@implementation NotesAppController

+ (NotesAppController*)sharedInstance
{
    static NotesAppController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NotesAppController alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}

- (void)initObject
{
    //[PYClient setDefaultDomainStaging];
    [PYClient setLanguageCodePrefered:kLocalizedKey];
    
    _settingController = [[SettingsController alloc] init];
    [self loadSavedConnection];
}

- (void)loadSavedConnection
{
    NSString *lastUsedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedUsernameKey];
    if(lastUsedUsername)
    {
        NSString *accessToken = [SSKeychain passwordForService:kServiceName account:lastUsedUsername];
        self.connection = [[PYConnection alloc] initWithUsername:lastUsedUsername andAccessToken:accessToken];
        TFLog(@"LoadedSavedConnection: %@", lastUsedUsername);
    }
}

- (void)setConnection:(PYConnection *)connection
{
    if (connection != nil) {
        TFLog(@"setConnection: %@", connection.userID);
    }
    if(connection != _connection)
    {
        [self removeConnection:_connection];
        _connection = connection;
        [self saveConnection:connection];
    }
    if(_connection)
    {
       
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveAccessTokenNotification object:nil];
    }
    else
    {
        //[self userDidLogout];
    }
}

- (void)userDidLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
}

- (void)saveConnection:(PYConnection *)connection
{
    [[NSUserDefaults standardUserDefaults] setObject:connection.userID forKey:kLastUsedUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SSKeychain setPassword:connection.accessToken forService:kServiceName account:connection.userID];
}

- (void)removeConnection:(PYConnection *)connection
{
    [SSKeychain deletePasswordForService:kServiceName account:connection.userID];
}

- (BOOL)isOnline
{
    return _connection.onlineStatus;
}

+ (void)sharedConnectionWithID:(NSString*)connectionID
    noConnectionCompletionBlock:(NoConnectionCompletionBlock)noConnectionCompletionBlock
     withCompletionBlock:(SharedConnectionCompletionBlock)completionBlock {
    
    if (connectionID) {
        NSLog(@"<WARNING> NotesAppController.sharedConnection connectionID to be implemented!!");
    }
    
    NotesAppController *me = [NotesAppController sharedInstance];
    if (! me.connection) {
        if (noConnectionCompletionBlock) noConnectionCompletionBlock();
        return ;
    }
    if (completionBlock) {
        [me.connection streamsEnsureFetched:^(NSError *error) {
            completionBlock(me.connection);
        }];
        
    };
}

- (NSDateFormatter*)dateFormatter
{
    if(!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setDoesRelativeDateFormatting:YES];
    }
    return _dateFormatter;
}

@end
