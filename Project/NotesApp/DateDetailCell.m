//
//  DateDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DateDetailCell.h"
#import "DatePickerManager.h"

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
    if (![self.event eventDate])
        self.event.eventDate = [NSDate date];
    
    [[DatePickerManager sharedInstance].datePicker setHidden:NO];
    [[DatePickerManager sharedInstance].timePicker setHidden:YES];
    
    [[DatePickerManager sharedInstance].datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].timePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self update];
}

-(void) update
{
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:self.event.eventDate];
    [[DatePickerManager sharedInstance].timePicker setDate:self.event.eventDate];
    [[DatePickerManager sharedInstance].datePicker setDate:self.event.eventDate];
}

-(void)datePickerValueChanged:(id)sender
{
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:[DatePickerManager sharedInstance].datePicker.date];
    [[DatePickerManager sharedInstance].timePicker setDate:[DatePickerManager sharedInstance].datePicker.date];
    [self.event setEventDate:[DatePickerManager sharedInstance].datePicker.date];
    
    [self delegateShouldUpdateEvent];
}

-(void)timePickerValueChanged:(id)sender
{
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:[DatePickerManager sharedInstance].timePicker.date];
    [[DatePickerManager sharedInstance].datePicker setDate:[DatePickerManager sharedInstance].timePicker.date];
    [self.event setEventDate:[DatePickerManager sharedInstance].timePicker.date];
    [self delegateShouldUpdateEvent];
}

-(void) delegateShouldUpdateEvent
{
    [self.delegate detailShouldUpdateEvent];
    [self.delegate updateEndDateCell];
    //[[DatePickerManager sharedInstance].endDatePicker setMinimumDate:self.event.eventDate];
    //[[DatePickerManager sharedInstance].endTimePicker setMinimumDate:self.event.eventDate];
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

-(void) dealloc
{
    [[DatePickerManager sharedInstance].datePicker removeTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].timePicker removeTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
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
