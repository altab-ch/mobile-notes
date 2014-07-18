//
//  NotesAppController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/13/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingsController;
@class PYConnection;

typedef void (^NoConnectionCompletionBlock)(void);
typedef void (^SharedConnectionCompletionBlock)(PYConnection *connection);

#define kLocalizedKey NSLocalizedString(@"MeasurementSetLocalizedKey", nil)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)


extern NSString *const kAppDidReceiveAccessTokenNotification;
extern NSString *const kUserDidLogoutNotification;
extern NSString *const kUserShouldLoginNotification;
extern NSString *const kUserDidCreateEventNotification;
extern NSString *const kBrowserShouldUpdateNotification;
extern NSString *const kBrowserShouldScrollToEvent;
@interface NotesAppController : NSObject

@property (nonatomic, strong) PYConnection *connection;
@property (nonatomic, readonly) BOOL isOnline;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) SettingsController* settingController;

+ (NotesAppController*)sharedInstance;

/**
 *
 * @param connectionID optional nil for default
 */
+ (void)sharedConnectionWithID:(NSString*)connectionID
    noConnectionCompletionBlock:(NoConnectionCompletionBlock)noConnectionCompletionBlock
     withCompletionBlock:(SharedConnectionCompletionBlock)completionBlock;


@end
