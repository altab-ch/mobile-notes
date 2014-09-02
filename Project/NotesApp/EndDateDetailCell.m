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
    [self.lbDuration setEvent:event];
    
    [[DatePickerManager sharedInstance].endDatePicker addTarget:self action:@selector(endDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].endTimePicker addTarget:self action:@selector(endTimePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].endDatePicker setDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    [[DatePickerManager sharedInstance].endTimePicker setDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    
    if (event.duration == 0)
        [self reset];
    else if(event.isRunning)
        [self setAsRunning];
    else
        [self stopNow];
    
    /*[[DatePickerManager sharedInstance].endDatePicker setMinimumDate:[self.event eventDate]];
    [[DatePickerManager sharedInstance].endTimePicker setMinimumDate:[self.event eventDate]];
    [self syncDatePickers];*/
}

-(void)endDatePickerValueChanged:(id)sender
{
    self.lbState.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:[DatePickerManager sharedInstance].endDatePicker.date];
    [self.lbDuration setEndDate:[DatePickerManager sharedInstance].endDatePicker.date];
    
    [[DatePickerManager sharedInstance].endTimePicker setDate:[DatePickerManager sharedInstance].endDatePicker.date];
    [self.event setDuration:[[DatePickerManager sharedInstance].endDatePicker.date timeIntervalSinceDate:self.event.eventDate]];
    
    [self delegateShouldUpdateEvent];
}

-(void)endTimePickerValueChanged:(id)sender
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
    
    else if (self.event.isRunning) {
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
    
    else {
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
    /*if ([self.event.eventDate compare:[NSDate date]] == NSOrderedAscending) {
     
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Detail.CantRun", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }*/
    [self setIsInEditMode:YES];
    [self.lbDuration setEndDate:nil];
    [self.lbState setText:@"Running"];
    [self.event setStateRunning];
    [self.setRunningView setHidden:NO];
    [self.addView setHidden:YES];
    [self delegateShouldUpdateEvent];
    [self.lbDuration start];
    
}

-(void) setEndDate
{
    if (self.event.isRunning) [self stopNow];
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
    //[self.lbDuration setEndDate:[NSDate date]];
    self.event.duration = [[NSDate date] timeIntervalSinceDate:self.event.eventDate];
    [self.lbDuration update];
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
    /*if (self.event.duration < 0){
        [[DatePickerManager sharedInstance].datePicker setMaximumDate:[NSDate date]];
        [[DatePickerManager sharedInstance].timePicker setMaximumDate:[NSDate date]];
    }else if (self.event.duration == 0){
        [[DatePickerManager sharedInstance].datePicker setMaximumDate:nil];
        [[DatePickerManager sharedInstance].timePicker setMaximumDate:nil];
    }else if (self.event.duration > 0){
        [[DatePickerManager sharedInstance].datePicker setMaximumDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
        [[DatePickerManager sharedInstance].timePicker setMaximumDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]];
    }*/
}

#pragma mark - Border

-(void) didSelectCell:(UIViewController *)controller
{
    if (self.event.isRunning)
        [self stopNow];
    else
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
    if (self.event.isRunning)
    {
        [self.lbDuration stop];
        [self.lbDuration update];
        [self.lbDuration start];
    }
    else if (self.event.duration != 0)
    {
        [self.lbDuration update];
        [self.lbState setText:[[NotesAppController sharedInstance].dateFormatter stringFromDate:[self.event.eventDate dateByAddingTimeInterval:self.event.duration]]];
    }
}

-(UIActionSheet*)getActionSheet
{
    UIActionSheet *actionSheet;
    if (self.event.duration == 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Detail.SetAsRunning", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }else if (self.event.isRunning) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Detail.StopNow", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Detail.SetAsRunning", nil),NSLocalizedString(@"Detail.SetEndDate", nil), nil];
    }
    return actionSheet;
}

-(void) dealloc
{
    [[DatePickerManager sharedInstance].endDatePicker removeTarget:self action:@selector(endDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[DatePickerManager sharedInstance].endTimePicker removeTarget:self action:@selector(endTimePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
}

@end
