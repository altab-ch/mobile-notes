//
//  StreamDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "StreamDetailCell.h"
#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"

@interface StreamDetailCell ()

@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;
@property (nonatomic, weak) IBOutlet UIView *pastille;

@end

@implementation StreamDetailCell

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
    _streamsLabel.text = [event eventBreadcrumbs];
    if (event.stream) [_pastille setBackgroundColor:[[event stream] getColor]];
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    if (!isInEditMode) [self.streamsLabel setTextColor:[UIColor blackColor]];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    return 54;
}

@end
