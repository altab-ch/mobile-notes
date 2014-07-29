//
//  EventDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseViewController.h"



@class PYEvent,UserHistoryEntry,TextEditorViewController,AddNumericalValueViewController;

@interface EventDetailsViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) PYEvent *event;
@property (nonatomic) UIImagePickerControllerSourceType imagePickerType;



@end
