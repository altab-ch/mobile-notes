//
//  StreamPickerViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@class UserHistoryEntry;

@protocol StreamsPickerDelegate;

@interface StreamPickerViewController : BaseViewController

@property (nonatomic, weak) id<StreamsPickerDelegate> delegate;
@property (nonatomic, weak) NSString *streamId;
@property (nonatomic, weak) UserHistoryEntry *entry;

@property (nonatomic, weak) IBOutlet UILabel *streamLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@protocol StreamsPickerDelegate <NSObject>

- (void)closeStreamPicker;
- (void)streamPickerDidSelectStream:(PYStream*)stream;

@end
