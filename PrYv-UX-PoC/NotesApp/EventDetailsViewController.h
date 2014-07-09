//
//  EventDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseViewController.h"



@class PYEvent,UserHistoryEntry,TextEditorViewController,AddNumericalValueViewController;

@interface EventDetailsViewController : UITableViewController

@property (nonatomic, strong) PYEvent *event;
@property (nonatomic) UIImagePickerControllerSourceType imagePickerType;

- (void)setupNoteContentEditorViewController:(TextEditorViewController*)textEditorVC;
- (void)setupDescriptionEditorViewController:(TextEditorViewController*)textEditorVC;
- (void)setupAddNumericalValueViewController:(AddNumericalValueViewController*)addNumericalValueVC;

- (IBAction)deleteButtonTouched:(id)sender;

@end
