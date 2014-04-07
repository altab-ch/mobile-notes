//
//  BrowseEventsCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@class UserHistoryEntry;

@interface BrowseEventsCell : MCSwipeTableViewCell

- (void)setupWithUserHistroyEntry:(UserHistoryEntry*)entry;

@end
