//
//  MenuNavController.h
//  NotesApp
//
//  Created by Mathieu Knecht on 02.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuNavController : UINavigationController

- (void) resetMenu;
- (NSArray*) getMenuStreams;
- (NSDate*) getDate;
- (void) initStreams;
- (void) reload;
- (void) addStream:(NSString*)streamName;
@end
