//
//  ChartView.h
//  NotesApp
//
//  Created by Mathieu Knecht on 19.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NumberAggregateEvents;

@protocol ChartViewDelegate <NSObject>

-(void) didSelectEvents:(NSArray*)events withType:(NSString*)type value:(NSString*)value date:(NSString*)date;
-(void) updateInfo:(NSString*)type value:(NSString*)value unit:(NSString*)unit description:(NSString*)description;

@end

@interface ChartView : UIScrollView

-(void) updateWithAggregateEvents:(NumberAggregateEvents*)aggEvents;

@property (nonatomic, assign) id<ChartViewDelegate> chartDelegate;

@end
