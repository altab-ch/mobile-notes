//
//  BaseWithMenuViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseWithMenuViewController : BaseViewController <UITableViewDataSource ,UITableViewDelegate>

@property (nonatomic, getter = isMenuOpen) BOOL menuOpen;
@property (nonatomic) BOOL enabled;

- (void)setMenuVisible:(BOOL)visible animated:(BOOL)animated withCompletionBlock:(void (^) (void))completionBlock;
- (void)topMenuDidSelectOptionAtIndex:(NSInteger)index;
- (void)topMenuVisibilityDidChange;
- (void)topMenuVisibilityWillChange;

@end
