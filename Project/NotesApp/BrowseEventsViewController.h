//
//  BrowseEventsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserSection.h"
#import "PYEvent+Helper.h"
#import "CellStyleModel.h"

@interface BrowseEventsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)toggleSlider;
- (void)unsetFilter;

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) PYEventFilter *filter;
@property (nonatomic) BOOL displayNonStandardEvents;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
