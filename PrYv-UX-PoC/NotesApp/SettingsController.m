//
//  SettingsController.m
//  NotesApp
//
//  Created by Perki on 12.12.13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "SettingsController.h"
#import "AppConstants.h"

@interface SettingsController ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;

@end

@implementation SettingsController

-(SettingsController*) init {
    self = [super init];
    if(self)
    {
        _userDefaults = [NSUserDefaults standardUserDefaults];

        
        [self loadDefault];
        [self monitorSettingsToSaveOnBackend];
    }
    
    return self;
}


- (void)monitorSettingsToSaveOnBackend {
    NSArray* keysOfSettingsToSaveOnBackend = @[kPYAppSettingUIDisplayNonStandardEvents, kPYAppSettingMeasurementSetsKey];
    for(NSString *aKey in keysOfSettingsToSaveOnBackend) {
        [_userDefaults addObserver:self
                        forKeyPath:aKey
                           options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    }
}


- (void)loadDefault {
    //A revoir : lors d'un changement de version, nettoyer le NSUserDefaults
    
    /*NSDictionary* ensureClass =
    @{
      kPYAppSettingMeasurementSetsKey : [NSArray class]
      };
    
    NSDictionary* defaults =
    @{kPYAppSettingMeasurementSetsKey : [[NSMutableArray alloc] init],
      kPYAppSettingUIDisplayNonStandardEvents : @NO
      };
    
    
    for(NSString *aKey in ensureClass) {
        NSObject* value = [_userDefaults objectForKey:aKey];
        if (value != nil || ! [value isKindOfClass:(Class)[ensureClass objectForKey:aKey]]) {
            NSLog(@"<WARNING> SettingsController.loadDefault key %@ was not of the expected type (%@) value : %@"
                  , aKey, [ensureClass objectForKey:aKey], value);
            [_userDefaults removeObjectForKey:aKey];
        }
        
    }
    
    
    [_userDefaults registerDefaults:defaults];
    
    NSLog(@"<DEBUG Settings> %@",[_userDefaults dictionaryRepresentation]);
    
    
    */
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    NSLog(@"Defaults changed, %@ %@", keyPath, change);
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
