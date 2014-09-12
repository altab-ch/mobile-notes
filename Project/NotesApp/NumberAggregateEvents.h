//
//  NumberAggregateEvents.h
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateEvents.h"

typedef enum{
    AggregationAverage = 0,
    AggregationTotal = 1
}NumberAggregation;

@interface NumberAggregateEvents : AggregateEvents

@property (nonatomic) NumberAggregation numberAggregation;

@end
