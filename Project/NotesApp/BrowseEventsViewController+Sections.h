//
//  BrowseEventsViewController+Sections.h
//  NotesApp
//
//  Created by Mathieu Knecht on 11.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseEventsViewController.h"
#import "BrowseCell.h"

@interface BrowseEventsViewController (Sections)

-(BrowseCell*)cellAtIndex:(NSIndexPath*)index;
-(UIView *) viewForHeaderInSection:(NSInteger)section;
-(NSUInteger)numberOfSection;
-(NSUInteger)numberOfRowInSection:(NSUInteger)section;
-(CGFloat) heightForCell:(NSIndexPath *)indexPath;
-(void)buildSections;
-(void)addEventToSections:(PYEvent*)event;
-(void)clearCurrentData;
-(id) getEventsForIndex:(NSIndexPath*)index;
-(void) didSelectRowAtIndexPath:(NSIndexPath*)indexpath;

@end
