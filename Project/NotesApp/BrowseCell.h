//
//  BrowseCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYEvent+Helper.h"
#import "TagContainer.h"
#import "DurationLabel.h"
#import "AggregateEvents.h"

@interface BrowseCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *streamLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentLabel;
@property (nonatomic, strong) IBOutlet TagContainer *tagContainer;
@property (nonatomic, strong) IBOutlet UIView *streamContainer;
@property (nonatomic, strong) IBOutlet DurationLabel *duration;
@property (nonatomic, weak) IBOutlet UIView *pastille;
@property (nonatomic, weak) IBOutlet UIView *backView;
@property (nonatomic, weak) PYEvent *event;
@property (nonatomic, weak) AggregateEvents *aggEvents;

- (void)updateWithEvent:(PYEvent*)event;
- (void)updateWithAggregateEvent:(AggregateEvents*)aggEvent;

@end
