//
//  PhotoDetailCell.h
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseDetailCell.h"
#import "EventDetailCellDelegate.h"

@interface PhotoDetailCell : BaseDetailCell

@property (nonatomic, assign) id<EventDetailCellDelegate> eventDelegate;

@end
