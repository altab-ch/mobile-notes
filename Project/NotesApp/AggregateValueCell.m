//
//  AggregateValueCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 12.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "AggregateValueCell.h"
#import "NumberAggregateEvents.h"

@implementation AggregateValueCell

- (void)updateWithAggregateEvent:(NumberAggregateEvents*)aggEvent
{
    [super updateWithEvent:[aggEvent.events objectAtIndex:0]];
    
    self.aggEvents = aggEvent;
    
    __block double val = 0.0;
    
    if (aggEvent.transform == TransformAverage) {
        [aggEvent.events enumerateObjectsUsingBlock:^(PYEvent* obj, NSUInteger idx, BOOL *stop){
            val += [obj.eventContent doubleValue];
        }];
        val = val/[aggEvent.events count];
        [self.numberAggregation setText:NSLocalizedString(@"Average", nil)];
    }else{
        [aggEvent.events enumerateObjectsUsingBlock:^(PYEvent* obj, NSUInteger idx, BOOL *stop){
            val += [obj.eventContent doubleValue];
        }];
        [self.numberAggregation setText:NSLocalizedString(@"Total", nil)];
    }
    
    NSNumberFormatter *numf = [[NSNumberFormatter alloc] init];
    [numf setNumberStyle:NSNumberFormatterDecimalStyle];
    if ([[numf stringFromNumber:[NSNumber numberWithDouble:val]] rangeOfString:@"."].length != 0){
        [numf setMinimumFractionDigits:2];
    }else{
        [numf setMaximumFractionDigits:0];
    }
    
    NSString *unit = [aggEvent.pyType symbol];
    NSString *formatDescription = [aggEvent.pyType localizedName];
    if (! unit) {
        unit = formatDescription ;
        [self.formatDescriptionLabel setText:@""];
    } else {
        [self.formatDescriptionLabel setText:formatDescription];
    }
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[numf stringFromNumber:[NSNumber numberWithDouble:val]], unit];
    [self.valueLabel setText:value];
    
}

@end
