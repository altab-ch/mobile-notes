//
//  DatePickerDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DatePickerDetailCell.h"
#import "DatePickerManager.h"

@interface DatePickerDetailCell ()

@property (nonatomic, weak) UIDatePicker *datePicker;
@property (nonatomic, weak) UIDatePicker *timePicker;

@end

@implementation DatePickerDetailCell

-(void) updateWithEvent:(PYEvent*)event
{
    //[super updateWithEvent:event];
    /*if (_isEndDate) {
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
    }*/
    
    self.datePicker = [DatePickerManager sharedInstance].datePicker;
    [self addSubview:self.datePicker];
    
    self.timePicker = [DatePickerManager sharedInstance].timePicker;
    [self.timePicker setHidden:YES];
    [self addSubview:self.timePicker];
    
}

- (IBAction)segmentSwitch:(UISegmentedControl*)seg {
    
    NSInteger selectedSegment = seg.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [self.datePicker setHidden:NO];
        [self.timePicker setHidden:YES];
    }
    else{
        [self.timePicker setHidden:NO];
        [self.datePicker setHidden:YES];
    }
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return NO;
}

-(CGFloat) getHeight
{
    return 210;
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
