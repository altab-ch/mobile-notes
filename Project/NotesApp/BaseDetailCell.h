//
//  BaseDetailCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/23/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailCellDelegate.h"

@interface BaseDetailCell : UITableViewCell

@property (nonatomic) BOOL isInEditMode;
@property (nonatomic, weak) PYEvent *event;
@property (nonatomic, assign) id<DetailCellDelegate> delegate;

-(CGFloat) getHeight;
-(void) updateWithEvent:(PYEvent*)event;
-(void) didSelectCell:(UIViewController*)controller;
-(void) update;

@end
