//
//  BrowseCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseCell.h"
#import "TagView.h"

@interface BrowseCell ()

@property (nonatomic, weak) PYEvent *event;

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
    self.event = event;
    self.commentLabel.text = event.eventDescription;
    self.streamLabel.text = [event eventBreadcrumbs];
    
    if ([[event stream] clientData] && [[[event stream] clientData] objectForKey:@"pryv-browser:bgColor"])
        [[self pastille] setBackgroundColor:[self colorFromHexString:[[[event stream] clientData] objectForKey:@"pryv-browser:bgColor"]]];
    
    [self updateTags:event.tags];
    
    NSDate *date = [event eventDate];
    //ajouter variable enum et définir à la création de la cell dans browser
    /*if (aggregation==jour) {
        [[NotesAppController sharedInstance].dateFormatter setDateStyle:NSDateFormatterNoStyle];
    }*/
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)layoutSubviews
{
    CGRect descLabelFrame = self.commentLabel.frame;
    
    /*if([self.event.tags count] > 0)
    {
        descLabelFrame.origin.y = 92;
    }
    else*/
    if([self.event.tags count] <= 0)
    {
        descLabelFrame.origin.y = self.bounds.size.height - descLabelFrame.size.height;
    }
    
    self.commentLabel.frame = descLabelFrame;
}

@end
