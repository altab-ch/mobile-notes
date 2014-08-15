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
    [self update];
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    if (!isInEditMode) [self.streamsLabel setTextColor:[UIColor blackColor]];
}

#pragma mark - Border

-(void) update
{
    self.streamsLabel.text = [self.event eventBreadcrumbs];
    if (self.event.stream) [_pastille setBackgroundColor:[[self.event stream] getColor]];
}

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    return 54;
}

@end
