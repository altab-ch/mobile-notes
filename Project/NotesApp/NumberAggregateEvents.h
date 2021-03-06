//
//  NumberAggregateEvents.h
//  NotesApp
//
//  Created by Mathieu Knecht on 10.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateEvents.h"

typedef enum {
    GraphStyleBar = 0,
    GraphStyleLine,
    GraphStyleLineJoined,
    GraphStyleArea
}GraphStyle;

typedef enum{
    TransformNone = 0,
    TransformAverage,
    TransformSum
}Transform;

typedef enum{
    IntervalMonth = 1,
    IntervalWeek,
    IntervalDay,
    IntervalHour
}Interval;

typedef enum{
    HistoryYear = 1,
    HistoryMonth,
    HistoryWeek,
    HistoryDay
}History;

@interface NumberAggregateEvents : AggregateEvents

@property (nonatomic) Transform transform;
@property (nonatomic) GraphStyle graphStyle;
@property (nonatomic) Interval interval;
@property (nonatomic) History history;
//@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSMutableArray *sortedEvents;
@property (nonatomic, strong) NSDate *startDate, *endDate;
@property (nonatomic, strong) PYStream *stream;

-(NSString*) historyLocalized;
-(NSString*) typeLocalized;
-(NSString*) intervalLocalized;
-(NSString*) graphStyleLocalized;
@end
