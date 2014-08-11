//
//  NumericDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "NumericDetailCell.h"
#import "PYEvent+Helper.h"
#import "ZenKeyboard.h"

@interface NumericDetailCell ()

@property (nonatomic, weak) IBOutlet UILabel *numericalValue_Label;
@property (nonatomic, weak) IBOutlet UILabel *numericalValue_TypeLabel;
@property (nonatomic, weak) IBOutlet UITextField *numericalValue;

@end

@implementation NumericDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    
    [_numericalValue_TypeLabel setText:[event.pyType localizedName]];
    [_numericalValue_Label setText:[event.pyType symbol]];
    [_numericalValue setText:[self getNumericalValueFormatted:event]];
    
    ZenKeyboard *keyboard = [[ZenKeyboard alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
    [keyboard setTextField:_numericalValue];
}

-(NSString*) getNumericalValueFormatted:(PYEvent*)event
{
    NSString *value = NULL;
    if ([event.eventContent isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *numf = [[NSNumberFormatter alloc] init];
        [numf setNumberStyle:NSNumberFormatterDecimalStyle];
        if ([[numf stringFromNumber:event.eventContent] rangeOfString:@"."].length != 0){
            [numf setMinimumFractionDigits:2];
        }else{
            [numf setMaximumFractionDigits:0];
        }
        
        value = [numf stringFromNumber:event.eventContent];
    }else{
        value = event.eventContentAsString;
    }
    return value;
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [_numericalValue setEnabled:isInEditMode];
    if (self.event.isDraft && isInEditMode) [_numericalValue becomeFirstResponder];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
