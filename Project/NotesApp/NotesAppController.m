//
//  NotesAppController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/13/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "NotesAppController.h"
#import <PryvApiKit/PryvApiKit.h>
#import "PYStream+Utils.h"
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
NSString *const kUserDidAddStreamNotification = @"kUserDidAddStreamNotification";
NSString *const kBrowserShouldUpdateNotification = @"kBrowserShouldUpdateNotification";
NSString *const kBrowserShouldScrollToEvent = @"kBrowserShouldScrollToEvent";
NSString *const kBrowserShouldScrollToTop = @"kBrowserShouldScrollToTop";


@interface NotesAppController ()

- (void)initObject;
- (void)userDidLogout;
- (void)loadSavedConnection;
- (void)saveConnection:(PYConnection*)connection;
- (void)removeConnection:(PYConnection*)connection;
- (void)setupConnection:(PYConnection*)connection;

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
    
    self.sectionKeyFormatter = [[NSDateFormatter alloc] init];
    [self.sectionKeyFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.numf = [[NSNumberFormatter alloc] init];
    [self.numf setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.numf setMaximumFractionDigits:2];
    
    self.sectionTitleFormatter = [[NSDateFormatter alloc] init];
    [self.sectionTitleFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.sectionTitleFormatter setDoesRelativeDateFormatting:YES];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    //[self.cellDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.cellDateFormatter setDoesRelativeDateFormatting:YES];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    
    /*switch (self.aggregationStep) {
        case AggregationStepMonth:
            [self.sectionsKeyFormatter setDateFormat:@"yyyy-MM"];
            break;
        case AggregationStepYear:
            [self.sectionsKeyFormatter setDateFormat:@"yyyy"];
            break;
        default:
            [self.sectionsKeyFormatter setDateFormat:@"yyyy-MM-dd"];
            [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
            break;
    }*/
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
        [self setupConnection:connection];
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

+(NSString*) durationFromDate:(NSDate*)date toDate:(NSDate*)endDate
{
    NSInteger duration = (NSInteger)[endDate timeIntervalSinceDate:date];
    return [self durationFormatter:duration];
}

+(NSString*) durationFormatter:(double)duration
{
    
    BOOL isMinus = false;
    if (duration<0) {
        duration = abs(duration);
        isMinus = true;
    }
    
    NSInteger d = duration;
    NSString *result;
   
   
    NSInteger seconds = d % 60;
    NSInteger minutes = (d / 60) % 60;
    NSInteger hours = (d / 3600);
    NSString* time;
    
    if (hours >= 24)
        time=[NSString stringWithFormat:NSLocalizedString(@"duration.template.day", nil), hours/24, hours%24];
    else if (hours>0)
        time=[NSString stringWithFormat:NSLocalizedString(@"duration.template.hour", nil), (long)hours, (long)minutes];
    else
        time=[NSString stringWithFormat:NSLocalizedString(@"duration.template.minute", nil), (long)minutes, (long)seconds];
    
    if (isMinus)
        result = [NSString stringWithFormat:@"-%@", time];
    else
        result = [NSString stringWithFormat:@"%@", time];
    
    return result;
}

- (void)setupConnection:(PYConnection*)connection {
    [connection streamsEnsureFetched:^(NSError *error) {
        if (error) {
            NSLog(@"<FAIL> fetching stream at streamSetup");
            return;
        }
        PYStream* found = [PYStream findStreamMatchingId:@"diary"
                                                 orNames:@[@"Journal", @"Diary", @"Me"]
                                                  onList:connection.fetchedStreamsRoots];
        if (found) {
            NSLog(@"<INFO> Default diary stream id:%@ with name:%@ found", found.streamId, found.name);
            return;
        }
        PYStream* newDiary = [[PYStream alloc] init];
        newDiary.name = NSLocalizedString(@"DefaultDiaryStreamName", nil);
        newDiary.streamId = @"diary";
        [connection streamCreate:newDiary successHandler:^(NSString *createdStreamId) {
            NSLog(@"<INFO> CREATED default diary stream id:%@ with name:%@", newDiary.streamId, newDiary.name);
        } errorHandler:^(NSError *error) {
            NSLog(@"<FAIL> creating default diary stream");
        }];
    }];
}

-(BOOL) isIOS7
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        return true;
    return false;
}

@end
