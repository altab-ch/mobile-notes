//
//  DatePickerDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DatePickerDetailCell.h"

@interface DatePickerDetailCell ()

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet UIDatePicker *timePicker;

@end

@implementation DatePickerDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isEndDate = NO;
    }
    return self;
}

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    if (_isEndDate) {
        [_datePicker setDate:[event.eventDate dateByAddingTimeInterval:event.duration]];
        [_timePicker setDate:[event.eventDate dateByAddingTimeInterval:event.duration]];
        [_timePicker setMinimumDate:event.eventDate];
        [_datePicker setMinimumDate:event.eventDate];
    }else{
        NSDate *date = [event eventDate];
        if (date == nil) date = [NSDate date];
        [_datePicker setDate:date];
        [_timePicker setDate:date];
        //[_timePicker setMinimumDate:[NSDate dateWithTimeIntervalSince1970:0]];
        //[_datePicker setMinimumDate:[NSDate dateWithTimeIntervalSince1970:0]];
        [_datePicker setMinimumDate:nil];
        [_timePicker setMinimumDate:nil];
    }
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return NO;
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
