//
//  DatePickerDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EndDatePickerDetailCell.h"
#import "DatePickerManager.h"

@interface EndDatePickerDetailCell ()

@property (nonatomic, weak) UIDatePicker *datePicker;
@property (nonatomic, weak) UIDatePicker *timePicker;

@end

@implementation EndDatePickerDetailCell

-(void) updateWithEvent:(PYEvent*)event
{
    self.datePicker = [DatePickerManager sharedInstance].endDatePicker;
    [self.datePicker setHidden:NO];
    [self addSubview:self.datePicker];
    
    self.timePicker = [DatePickerManager sharedInstance].endTimePicker;
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
