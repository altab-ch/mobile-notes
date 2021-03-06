//
//  BrowseCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseCell.h"
#import "PYStream+Helper.h"
#import "PictureCell.h"
#import <QuartzCore/QuartzCore.h>
#import "TagLabel.h"
#import "StreamAccessory.h"
#import "DescriptionLabel.h"

@interface BrowseCell ()
@end

@implementation BrowseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithAggregateEvent:(AggregateEvents*)aggEvent
{

}

- (void)updateWithEvent:(PYEvent *)event
{
    for (UIView *vi in self.subviews) {
        if ([vi isKindOfClass:[StreamAccessory class]] || [vi isKindOfClass:[DescriptionLabel class]]) {
            [vi removeFromSuperview];
        }
        for (UIView *vi2 in vi.subviews) {
            if ([vi2 isKindOfClass:[StreamAccessory class]] || [vi2 isKindOfClass:[DescriptionLabel class]]) {
                [vi2 removeFromSuperview];
            }
        }
    }
    
    [self.backView.layer setBorderWidth:1];
    [self.backView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    //[_backView.layer setCornerRadius:4];
    
    self.event = event;
    self.duration.isHeader = true;
    self.commentLabel.text = event.eventDescription;
    if (self.streamLabel)
        self.streamLabel.text = [event eventBreadcrumbs];
    if (self.pastille)
        [[self pastille] setBackgroundColor:[[event stream] getColor]];
    
    NSDate *date = [event eventDate];

    if (self.dateLabel)
        self.dateLabel.text = [[NotesAppController sharedInstance].cellDateFormatter stringFromDate:date];
    
    [self.duration setEvent:event];
    [self.duration update];

    
    [self.tagContainer updateWithTags:event.tags];
}

@end
