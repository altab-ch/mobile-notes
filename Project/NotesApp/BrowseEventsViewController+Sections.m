//
//  BrowseEventsViewController+Sections.m
//  NotesApp
//
//  Created by Mathieu Knecht on 11.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseEventsViewController+Sections.h"
#import "BrowseCell.h"

@implementation BrowseEventsViewController (Sections)

-(BrowseCell*)cellAtIndex:(NSIndexPath*)index
{
    id data = [self getEventsForIndex:index];
    if ([data isKindOfClass:[PYEvent class]]) {
        [((PYEvent*)data).pyType isNumerical]
    }
}

- (BrowseCell *)cellForPYType:(PYEventType*)pyType
{
    BrowseCell *cell;
    if([pyType.key isEqualToString:@"picture/attached"])
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PictureCell_ID"];
    }
    else if(cellStyleType == CellStyleTypeText)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoteCell_ID"];
    }
    else if (cellStyleType == CellStyleTypeMeasure || cellStyleType == CellStyleTypeMoney)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ValueCell_ID"];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"UnkownCell_ID"];
    }
    return cell;
}

-(id) getEventsForIndex:(NSIndexPath*)index
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

- (void)buildSections {
    NSArray* events = nil;
    if (self.filter != nil) {
        [self.sections removeAllObjects];
        events = [self.filter currentEventsSet];
    }
    
    if (!events) return;
    
    for (PYEvent* event in events) {
        if ([self clientFilterMatchEvent:event]) {
            [self addEventToSections:event];
        }
    }
    
    /*NSArray* keys = [self.browserSections allKeys];
     keys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
     
     for (NSString * key in keys) {
     NSLog(@"%@", [self.browserSections objectForKey:key]);
     }*/
    
}

- (void)addEventToSections:(PYEvent*)event {
    
    NSString* sectionKey = [[NotesAppController sharedInstance].sectionKeyFormatter stringFromDate:event.eventDate];
    BrowserSection *section = [self.sections objectForKey:sectionKey];
    
    if (section) {
        [section addEvent:event];
    }else{
        BrowserSection *newSection = [[BrowserSection alloc] initWithDate:event.eventDate];
        [newSection addEvent:event];
        [self.sections setObject:newSection forKey:sectionKey];
    }
}

- (BOOL)clientFilterMatchEvent:(PYEvent*)event
{
    if (event.trashed) return NO;
    return self.displayNonStandardEvents || !([event cellStyle] == CellStyleTypeUnkown );
}

- (void)clearCurrentData
{
    [self buildSections];
    [self unsetFilter];
    [self.tableView reloadData];
}


@end
