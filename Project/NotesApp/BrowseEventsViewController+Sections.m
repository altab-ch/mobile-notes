//
//  BrowseEventsViewController+Sections.m
//  NotesApp
//
//  Created by Mathieu Knecht on 11.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseEventsViewController+Sections.h"

@implementation BrowseEventsViewController (Sections)

-(NSArray*) getEventsForIndex:(NSIndexPath*)index
{
    BrowserSection *section = [self.sections objectForKey:[self getSectionKeyForSection:index.section]];
    return [section getEventsForRow:index.row];
}

-(NSUInteger)numberOfSection
{
    return [self.sections count];
}

-(NSUInteger)numberOfRowInSection:(NSUInteger)section
{
    BrowserSection *sec = [self.sections objectForKey:[self getSectionKeyForSection:section]];
    return [sec numberOfRow];
}

-(NSString*) getSectionKeyForSection:(NSUInteger)section
{
    NSArray *keys = [self.sections allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [keys objectAtIndex:section];
}


@end
