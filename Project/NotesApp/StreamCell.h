//
//  StreamCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *streamName;
@property (nonatomic, weak) IBOutlet UIImageView *accessoryImageView;
@property (nonatomic) NSInteger index;

@property (copy) void (^streamAccessoryTappedHandler)(StreamCell *cell, NSInteger index);
@property (copy) void (^streamCellTappedHandler)(StreamCell *cell, NSInteger index);

@end
