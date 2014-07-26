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
@property (nonatomic, strong) IBOutlet UIView *streamContainer;
@property (nonatomic, weak) IBOutlet UIView *pastille;
@property (nonatomic, weak) IBOutlet UIView *backView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, weak) PYEvent *event;

- (void)updateTags:(NSArray*)tags;

- (void)updateWithEvent:(PYEvent*)event;

@end