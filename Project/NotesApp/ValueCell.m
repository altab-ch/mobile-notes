//
//  ValueCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ValueCell.h"
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>
#import "DescriptionLabel.h"

@implementation ValueCell

- (void)updateWithEvent:(PYEvent *)event
{
    [super updateWithEvent:event];
    
    NSNumberFormatter *numf = [[NSNumberFormatter alloc] init];
    [numf setNumberStyle:NSNumberFormatterDecimalStyle];
    if ([[numf stringFromNumber:event.eventContent] rangeOfString:@"."].length != 0){
        [numf setMinimumFractionDigits:2];
    }else{
        [numf setMaximumFractionDigits:0];
    }
    
    NSString *unit = [event.pyType symbol];
     NSString *formatDescription = [event.pyType localizedName];
    if (! unit) {
        unit = formatDescription ;
    [self.formatDescriptionLabel setText:@""];
    } else {
      [self.formatDescriptionLabel setText:formatDescription];
    }
    
    DescriptionLabel *desc = [[DescriptionLabel alloc] initWithText:self.event.eventDescription];
    [desc setFrame:CGRectMake(10, 90, desc.frame.size.width, desc.frame.size.height)];
    [desc setBackgroundColor:[UIColor clearColor]];
    [desc setTextColor:[UIColor darkGrayColor]];
    
    [self addSubview:desc];
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[numf stringFromNumber:event.eventContent], unit];
    [self.valueLabel setText:value];

}

@end
