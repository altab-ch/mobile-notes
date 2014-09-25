//
//  SChartView.m
//  NotesApp
//
//  Created by Mathieu Knecht on 24.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "SChartView.h"

@implementation SChartView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initChart];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initChart];
    }
    return self;
}

-(void) initChart
{
    
}

@end
