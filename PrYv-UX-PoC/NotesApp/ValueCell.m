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

@implementation ValueCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)updateWithEvent:(PYEvent *)event
{
   
    
    
    NSNumberFormatter *numf = [[NSNumberFormatter alloc] init];
    [numf setNumberStyle:NSNumberFormatterDecimalStyle];
    if (([[numf stringFromNumber:event.eventContent] rangeOfString:@"."].length != 0) || ([[numf stringFromNumber:event.eventContent] rangeOfString:@","].length != 0)) {
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
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[numf stringFromNumber:event.eventContent], unit];
    [self.valueLabel setText:value];
    

    
    
    
    [super updateWithEvent:event];
}

@end
