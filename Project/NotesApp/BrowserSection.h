//
//  BrowserSection.h
//  NotesApp
//
//  Created by Mathieu Knecht on 09.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowserSection : NSObject

-(id) initWithDate:(NSDate*)date;
-(NSInteger) addEvent:(PYEvent*) event;
-(void) sort;


@end
