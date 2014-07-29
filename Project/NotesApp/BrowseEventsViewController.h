//
//  BrowseEventsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseEventsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)toggleSlider;
- (void)clearCurrentData;

@end
