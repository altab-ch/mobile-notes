//
//  DatePickerManager.h
//  NotesApp
//
//  Created by Mathieu Knecht on 15.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatePickerManager : NSObject

+ (DatePickerManager*)sharedInstance;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIDatePicker *timePicker;
@property (nonatomic, strong) UIDatePicker *endDatePicker;
@property (nonatomic, strong) UIDatePicker *endTimePicker;

@end
