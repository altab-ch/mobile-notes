//
//  DatePickerManager.m
//  NotesApp
//
//  Created by Mathieu Knecht on 15.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DatePickerManager.h"

@implementation DatePickerManager

+ (DatePickerManager*)sharedInstance
{
    static DatePickerManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DatePickerManager alloc] init];
    });
    return _sharedInstance;
}

-(id)init{
    self = [super init];
    if(self){
        self.datePicker = [[UIDatePicker alloc] init];
        [self.datePicker setPosition:CGPointMake(0, 38)];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        self.timePicker = [[UIDatePicker alloc] init];
        [self.timePicker setPosition:CGPointMake(0, 38)];
        [self.timePicker setDatePickerMode:UIDatePickerModeTime];
        
        self.endDatePicker = [[UIDatePicker alloc] init];
        [self.endDatePicker setPosition:CGPointMake(0, 38)];
        [self.endDatePicker setDatePickerMode:UIDatePickerModeDate];
        self.endTimePicker = [[UIDatePicker alloc] init];
        [self.endTimePicker setPosition:CGPointMake(0, 38)];
        [self.endTimePicker setDatePickerMode:UIDatePickerModeTime];
    }
    return self;
}

@end
