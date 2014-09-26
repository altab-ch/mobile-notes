//
//  BrowseEventsViewController+Sections.m
//  NotesApp
//
//  Created by Mathieu Knecht on 11.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseEventsViewController+Sections.h"
#import "AggregateEvents.h"
#import "BarCell.h"
#import "LineCell.h"

#define kSectionCell @"section_cell_id"
#define kSectionLabel 10

@implementation BrowseEventsViewController (Sections)

-(BrowseCell*)cellAtIndex:(NSIndexPath*)index
{
    if (![self.sections count]) return [self.tableView dequeueReusableCellWithIdentifier:@"add_new_cell_id"];

    BrowseCell *cell = nil;
    id data = [self getEventsForIndex:index];
    if ([data isKindOfClass:[PYEvent class]]) {
        cell = [self cellForPYType:((PYEvent*)data).pyType];
        if (cell)
            [cell updateWithEvent:(PYEvent*)data];
    }
    else if ([data isKindOfClass:[AggregateEvents class]])
    {
        cell = [self aggregateCellForPYType:((AggregateEvents*)data).pyType];
        if (cell)
            [cell updateWithAggregateEvent:(AggregateEvents*)data];
        else
            NSLog(@"cant create cell");
    }else
    {
        NSLog(@"unknown data");
    }
    
    if (cell==nil) {
        NSLog(@"cell is nil");
    }
    
    return cell;
}

-(void) didSelectRowAtIndexPath:(NSIndexPath*)indexpath
{
    id data = [self getEventsForIndex:indexpath];
    if ([data isKindOfClass:[AggregateEvents class]]) [self performSegueWithIdentifier:@"AggregateEventsSegue_ID" sender:data];
    
}

-(UIView *) viewForHeaderInSection:(NSInteger)section
{
    if ([self.sections count] == 0) return nil;
    
    UITableViewCell *headerCell = [self.tableView dequeueReusableCellWithIdentifier:kSectionCell];
    UILabel *targetedLabel = (UILabel *)[headerCell viewWithTag:kSectionLabel];
    
    [headerCell.contentView setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:0.8]];
    
    [targetedLabel setText:[[self.sections objectForKey:[self getSectionKeyForSection:section]] title]];
    
    return headerCell.contentView;
}

- (BrowseCell *)cellForPYType:(PYEventType*)pyType
{
    BrowseCell *cell = nil;
    if([pyType.key isEqualToString:@"picture/attached"]) cell = [self.tableView dequeueReusableCellWithIdentifier:@"PictureCell_ID"];
    else if([pyType.key isEqualToString:@"note/txt"]) cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoteCell_ID"];
    else if ([pyType isNumerical]) cell = (BarCell*)[[[NSBundle mainBundle] loadNibNamed:@"BarCell" owner:cell options:nil] objectAtIndex:0];//[self.tableView dequeueReusableCellWithIdentifier:@"ValueCell_ID"];
    else cell = [self.tableView dequeueReusableCellWithIdentifier:@"UnkownCell_ID"];
    return cell;
}

- (BrowseCell *)aggregateCellForPYType:(PYEventType*)pyType
{
    BrowseCell *cell = nil;
    if([pyType isNumerical]){
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"LineCell"];
        //cell = (LineCell*)[[[NSBundle mainBundle] loadNibNamed:@"LineCell" owner:cell options:nil] objectAtIndex:0];
    }
    else if([pyType.key isEqualToString:@"position/wgs84"]) cell = [self.tableView dequeueReusableCellWithIdentifier:@"Map_ID"];
    return cell;
}

-(id) getEventsForIndex:(NSIndexPath*)index
{
    BrowserSection *section = [self.sections objectForKey:[self getSectionKeyForSection:index.section]];
    return [section getEventsForRow:index.row];
}

-(NSUInteger)numberOfSection
{
    if ([self.sections count] ==0)
        return 1;
    
    return [self.sections count];
}

-(NSUInteger)numberOfRowInSection:(NSUInteger)section
{
    if ([self.sections count] ==0)
        return 1;
    
    BrowserSection *sec = [self.sections objectForKey:[self getSectionKeyForSection:section]];
    return [sec numberOfRow];
}

-(NSString*) getSectionKeyForSection:(NSUInteger)section
{
    NSArray *keys = [self.sections allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    keys = [[keys reverseObjectEnumerator] allObjects];
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
    
    [self.sections enumerateKeysAndObjectsUsingBlock:^(NSString* key, BrowserSection* obj, BOOL *stop){
        [obj sortAll];
    }];
    
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

-(CGFloat) heightForCell:(NSIndexPath *)indexPath
{
    if ([self.sections count] ==0)
        return 60;
    
    CGFloat result = 100.0;
    
    id data = [self getEventsForIndex:indexPath];
    if ([data isKindOfClass:[PYEvent class]]) result = [self heightForPYType:((PYEvent*)data).pyType];
    else if ([data isKindOfClass:[AggregateEvents class]]) result = [self aggregateHeightForPYType:((AggregateEvents*)data).pyType];
    
    return result;
}

- (CGFloat)heightForPYType:(PYEventType*)pyType
{
    CGFloat height = 100;
    if([pyType.key isEqualToString:@"picture/attached"]) height = 160;
    else if([pyType.key isEqualToString:@"note/txt"]) height = 124;
    else if ([pyType isNumerical]) height = 132;
    
    return height;
}

- (CGFloat)aggregateHeightForPYType:(PYEventType*)pyType
{
    CGFloat height = 100;
    if([pyType isNumerical]) height = 104;
    else if([pyType.key isEqualToString:@"position/wgs84"]) height = 130;
    
    return height;
}

- (BOOL)clientFilterMatchEvent:(PYEvent*)event
{
    if (event.trashed) return NO;
    return self.displayNonStandardEvents || !([event cellStyle] == CellStyleTypeUnkown );
}

- (void)clearCurrentData
{
    //[self buildSections];
    [self unsetFilter];
    //[self.tableView reloadData];
}


@end
