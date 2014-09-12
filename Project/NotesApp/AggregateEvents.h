//
//  AggregateEvents.h
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AggregateEvents : NSObject

-(id) initWithEvent:(PYEvent*)event;
-(BOOL) accept:(PYEvent*)event;
-(void) sort;

@property (nonatomic, strong) NSMutableArray* events;

+ (AggregateEvents*) createWithEvent:(PYEvent*)event;

@end
