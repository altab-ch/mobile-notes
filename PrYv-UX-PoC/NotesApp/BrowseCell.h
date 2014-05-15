//
//  BrowseCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYEvent+Helper.h"

@interface BrowseCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *streamLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentLabel;
@property (nonatomic, strong) IBOutlet UIView *tagContainer;
@property (nonatomic, weak) IBOutlet UIView *pastille;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)updateTags:(NSArray*)tags;

- (void)updateWithEvent:(PYEvent*)event;

@end
