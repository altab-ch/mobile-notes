//
//  EndDateDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EndDateDetailCell.h"
#import "DurationLabel.h"
#import "DatePickerManager.h"

@interface EndDateDetailCell () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIView* addView;
@property (nonatomic, weak) IBOutlet UIView* setRunningView;
@property (nonatomic, weak) IBOutlet DurationLabel* lbDuration;
@property (nonatomic, weak) IBOutlet UILabel* lbState;

@end

@implementation EndDateDetailCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isEndDatePicker = false;
    }
    return self;
}

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    [self.lbDuration setEventDate:event.eventDate];
    
    [[DatePickerManager sharedInstance].endDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].endTimePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].endDatePicker setDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    [[DatePickerManager sharedInstance].endTimePicker setDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    
    if (event.duration == 0) {
        [self reset];
    }else if(event.duration < 0){
        [self setAsRunning];
    }else if (event.duration > 0){
        [self stopNow];
    }
    [[DatePickerManager sharedInstance].endDatePicker setMinimumDate:[self.event eventDate]];
    [[DatePickerManager sharedInstance].endTimePicker setMinimumDate:[self.event eventDate]];
    [self syncDatePickers];
}

-(void)datePickerValueChanged:(id)sender
{
    self.lbState.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:[DatePickerManager sharedInstance].endDatePicker.date];
    [self.lbDuration setEndDate:[DatePickerManager sharedInstance].endDatePicker.date];
    
    [[DatePickerManager sharedInstance].endTimePicker setDate:[DatePickerManager sharedInstance].endDatePicker.date];
    [self.event setDuration:[[DatePickerManager sharedInstance].endDatePicker.date timeIntervalSinceDate:self.event.eventDate]];
    
    [self delegateShouldUpdateEvent];
}

-(void)timePickerValueChanged:(id)sender
{
    self.lbState.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:[DatePickerManager sharedInstance].endTimePicker.date];
    [self.lbDuration setEndDate:[DatePickerManager sharedInstance].endTimePicker.date];
    [[DatePickerManager sharedInstance].endDatePicker setDate:[DatePickerManager sharedInstance].endTimePicker.date];
    [self.event setDuration:[[DatePickerManager sharedInstance].endTimePicker.date timeIntervalSinceDate:self.event.eventDate]];
    
    [self delegateShouldUpdateEvent];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    if (self.event.duration == 0) {
        switch (buttonIndex) {
            case 0:
                [self setAsRunning];
                break;
                
            case 1:
                [self setEndDate];
                break;
                
            default:
                break;
        }
        
    }
    
    else if (self.event.duration < 0) {
        switch (buttonIndex) {
            case 0:
                [self reset];
                break;
                
            case 1:
                [self stopNow];
                break;
                
            case 2:
                [self setEndDate];
                break;
                
            default:
                break;
        }
    }
    
    else if (self.event.duration > 0) {
        switch (buttonIndex) {
            case 0:
                [self reset];
                break;
                
            case 1:
                [self setAsRunning];
                break;
                
            case 2:
                [self setEndDate];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - states

-(void) setAsRunning
{
    [self.lbState setText:@"Running"];
    [self.event setDuration:-1];
    [self.setRunningView setHidden:NO];
    [self.addView setHidden:YES];
    [self delegateShouldUpdateEvent];
    [self.lbDuration start];
}

-(void) setEndDate
{
    [self stopNow];
    self.isEndDatePicker = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void) stopNow
{
    [self.setRunningView setHidden:NO];
    [self.addView setHidden:YES];
    [self.lbDuration stop];
    [self.lbDuration setEndDate:[NSDate date]];
    self.event.duration = [[NSDate date] timeIntervalSinceDate:self.event.eventDate];
    [[DatePickerManager sharedInstance].endDatePicker setDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    [[DatePickerManager sharedInstance].endTimePicker setDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    [self.lbState setText:[[NotesAppController sharedInstance].dateFormatter stringFromDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]]];
    [self delegateShouldUpdateEvent];

}

-(void) reset
{
    [self.lbDuration stop];
    [self.event setDuration:0];
    [self.setRunningView setHidden:YES];
    [self.addView setHidden:NO];
    [self delegateShouldUpdateEvent];
}

-(void) delegateShouldUpdateEvent
{
    [self.delegate detailShouldUpdateEvent];
    [self syncDatePickers];
    
}

-(void) syncDatePickers
{
    if (self.event.duration < 0){
        [[DatePickerManager sharedInstance].datePicker setMaximumDate:[NSDate date]];
        [[DatePickerManager sharedInstance].timePicker setMaximumDate:[NSDate date]];
    }else if (self.event.duration == 0){
        [[DatePickerManager sharedInstance].datePicker setMaximumDate:nil];
        [[DatePickerManager sharedInstance].timePicker setMaximumDate:nil];
    }else if (self.event.duration > 0){
        [[DatePickerManager sharedInstance].datePicker setMaximumDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
        [[DatePickerManager sharedInstance].timePicker setMaximumDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    }
}

#pragma mark - Border

-(void) didSelectCell:(UIViewController *)controller
{
    [[self getActionSheet] showInView:controller.view];
}

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    if (self.event.duration == 0 && !self.isInEditMode) return 0;

    return 66;
}

#pragma mark - Utils

-(void) updateLabels
{
    if (self.event.duration < 0)
    {
        [self.lbDuration stop];
        [self.lbDuration setEventDate:self.event.eventDate];
        [self.lbDuration start];
    }
    else if (self.event.duration > 0)
    {
        [self.lbDuration setEventDate:self.event.eventDate];
        [self.lbState setText:[[NotesAppController sharedInstance].dateFormatter stringFromDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]]];
    }
}

-(UIActionSheet*)getActionSheet
{
    UIActionSheet *actionSheet;
    if (self.event.duration == 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detail.AddDuration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Detail.SetAsRunning", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    if (self.event.duration < 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detail.AddDuration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Detail.StopNow", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    if (self.event.duration > 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detail.AddDuration", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Detail.SetAsRunning", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    return actionSheet;
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
