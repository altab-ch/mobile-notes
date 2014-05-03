//
//  MenuTableViewController.h
//  NotesApp
//
//  Created by Mathieu Knecht on 02.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewController : UITableViewController
@property (strong, nonatomic) NSDate *date;

- (void)resetMenu;

@end
