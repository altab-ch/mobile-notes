//
//  xTimeAxis.m
//  NotesApp
//
//  Created by Mathieu Knecht on 26.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "xTimeAxis.h"

@implementation xTimeAxis

-(id) initWithRange:(SChartDateRange *)range
{
    self=[super initWithRange:range];
    if (self) {
        self.style.lineColor = [UIColor whiteColor];
        self.title = @"";
    }
    return self;
}

- (NSString *) formatStringForFrequency:(NSDateComponents *)frequency
{
    return @"HH:mm";
}

@end
