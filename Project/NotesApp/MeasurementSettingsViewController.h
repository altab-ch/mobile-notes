//
//  MeasurementSettingsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/27/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeasuresDelegate <NSObject>
@optional
- (void)measuresViewControllerDidChangeSets;
@end

@interface MeasurementSettingsViewController : UITableViewController

@property (nonatomic, strong) id<MeasuresDelegate> changeValueDelegate;

@end
