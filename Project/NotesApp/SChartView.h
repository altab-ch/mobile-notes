//
//  SChartView.h
//  NotesApp
//
//  Created by Mathieu Knecht on 24.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShinobiCharts/ShinobiCharts.h>

@class NumberAggregateEvents;

@protocol SChartViewDelegate <NSObject>

-(void) didSelectEvents:(NSArray*)events withType:(NSString*)type value:(NSString*)value date:(NSString*)date;
-(void) updateInfo:(NSString*)type value:(NSString*)value unit:(NSString*)unit description:(NSString*)description;

@end

@interface SChartView : ShinobiChart

-(void) updateWithAggregateEvents:(NumberAggregateEvents*)aggEvents;

@property (nonatomic, assign) id<SChartViewDelegate> chartDelegate;

@end
