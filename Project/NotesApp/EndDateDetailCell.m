//
//  EndDateDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EndDateDetailCell.h"
#import "DurationLabel.h"

@interface EndDateDetailCell ()

@property (nonatomic, weak) IBOutlet UIView* addView;
@property (nonatomic, weak) IBOutlet UIView* setRunningView;
@property (nonatomic, weak) IBOutlet DurationLabel* lbDuration;
@property (nonatomic, weak) IBOutlet UILabel* lbState;

@end

@implementation EndDateDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    if (event.duration == 0) {
        [_setRunningView setHidden:YES];
        [_addView setHidden:NO];
    }else{
        [_setRunningView setHidden:NO];
        [_addView setHidden:YES];
    }
    [_lbDuration setEventDate:event.eventDate];
    
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
