//
//  BrowseEventsViewController+Sections.h
//  NotesApp
//
//  Created by Mathieu Knecht on 11.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseEventsViewController.h"

@interface BrowseEventsViewController (Sections)

-(NSArray*) getEventsForIndex:(NSIndexPath*)index;
-(NSUInteger)numberOfSection;
-(NSUInteger)numberOfRowInSection:(NSUInteger)section;
-(void)buildSections;
-(void)addEventToSections:(PYEvent*)event;
-(void)clearCurrentData;

@end
