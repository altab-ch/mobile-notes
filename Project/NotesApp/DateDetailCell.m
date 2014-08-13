//
//  DateDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DateDetailCell.h"

@interface DateDetailCell ()

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@end

@implementation DateDetailCell

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
    NSDate *date = [event eventDate];
    if (!date)
    {
        date = [NSDate date];
        event.eventDate = date;
    }
    
    _timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:date];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    return 66;
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
