//
//  MapCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 12.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "MapCell.h"
#import "MapAggregateEvents.h"

@implementation MapCell

- (void)updateWithAggregateEvent:(MapAggregateEvents*)aggEvent
{
    [super updateWithEvent:[aggEvent.events objectAtIndex:0]];
    
    self.aggEvents = aggEvent;
    
}

@end
