//
//  BrowseEventsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseWithMenuViewController.h"

@interface BrowseEventsViewController : BaseWithMenuViewController

@property (nonatomic, strong) UIImage *pickedImage;
@property (nonatomic, strong) NSDate *pickedImageTimestamp;
@property (nonatomic) UIImagePickerControllerSourceType imagePickerType;

- (void)toggleSlider;
- (void)clearCurrentData;

@end
