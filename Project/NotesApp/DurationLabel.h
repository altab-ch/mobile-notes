//
//  DurationLabel.h
//  NotesApp
//
//  Created by Mathieu Knecht on 28.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DurationLabel : UILabel

@property(nonatomic, strong) PYEvent* event;
@property (nonatomic) BOOL isHeader;

-(void) update;

@end
