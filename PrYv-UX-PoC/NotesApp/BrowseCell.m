//
//  BrowseCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseCell.h"
#import "TagView.h"
#import "PYStream+Helper.h"
#import "PictureCell.h"
#import <QuartzCore/QuartzCore.h>

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

- (void)updateTags:(NSArray *)tags
{
    [self.tagContainer.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    int offset = 0;
    for(NSString *tag in tags)
    {
        TagView *tagView = [[TagView alloc] initWithText:tag andStyle:TagViewTransparentStyle];
        CGRect frame = tagView.frame;
        frame.origin.x = offset;
        offset+=frame.size.width + 4;
        tagView.frame = frame;
        [self.tagContainer addSubview:tagView];
    }
}

- (void)updateWithEvent:(PYEvent *)event
{
    [_backView.layer setBorderWidth:0.5];
    [_backView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    self.event = event;
    self.commentLabel.text = event.eventDescription;
    if (self.streamLabel)
        self.streamLabel.text = [event eventBreadcrumbs];
    if (self.pastille)
        [[self pastille] setBackgroundColor:[[event stream] getColor]];
    
    
    
    [self updateTags:event.tags];
    
    NSDate *date = [event eventDate];
    //ajouter variable enum et définir à la création de la cell dans browser
    /*if (aggregation==jour) {
        [[NotesAppController sharedInstance].dateFormatter setDateStyle:NSDateFormatterNoStyle];
    }*/
    if (self.dateLabel)
        self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    
    /*[self setNeedsLayout];
    [self layoutIfNeeded];*/
}

@end
