//
//  BrowseEventsCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseEventsCell.h"
#import "CellStyleModel.h"
#import "TagView.h"
#import "PYEvent+Helper.h"
#import "UserHistoryEntry.h"
#import <PryvApiKit/PYEventType.h>
#import <PryvApiKit/PYEventClass.h>

#define kScreenSize 320

@interface BrowseEventsCell ()

@property (nonatomic, strong) IBOutlet UILabel *streamBreadcrumbs;
@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UIView *tagContainer;
@property (nonatomic, strong) IBOutlet UILabel *symbolLabel;

- (NSString*)imageNameForType:(EventDataType)type;

@end

@implementation BrowseEventsCell

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

- (void)setupWithUserHistroyEntry:(UserHistoryEntry *)entry
{
    PYEvent *event = [entry reconstructEvent];
    [self updateTags:event.tags];
    self.streamBreadcrumbs.text = [event eventBreadcrumbs];
    
    
    NSString* symbol = [self symbolRepresentationForEventType:event.pyType];
    if (symbol) {
        self.symbolLabel.text = symbol;
        self.iconImageView.image = nil;
    } else {
        self.symbolLabel.text = @"";
        UIImage* iconImage = [UIImage imageNamed:[self imageNameForType:[event eventDataType]]];
        self.iconImageView.image = iconImage;
    }
    
    self.valueLabel.text = [self stringRepresentationForEventType:event.pyType];
}

- (NSString*)symbolRepresentationForEventType:(PYEventType*)eventType
{
    if ([eventType isNumerical]) {
        return [eventType symbol];
    }
    return nil;
    
}
        
        
- (NSString*)stringRepresentationForEventType:(PYEventType*)eventType
{
    if ([eventType isNumerical]) {
      
        return [NSString stringWithFormat:@"%@, %@", [eventType localizedName], [[eventType klass] localizedName]];
    }
    return @"";

}

- (NSString*)imageNameForType:(EventDataType)type
{
    switch (type) {
        case EventDataTypeValueMeasure:
            return @"icon_measure";
        case EventDataTypeImage:
            return @"icon_small_photo_grey";
        case EventDataTypeNote:
            return @"icon_small_text_grey";
        default:
            break;
    }
    return @"icon_small_text_grey";
}

- (void)updateTags:(NSArray *)tags
{
    [self.tagContainer.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    int offset = 0;
    for(NSString *tag in tags)
    {
        TagView *tagView = [[TagView alloc] initWithText:tag andStyle:TagViewStandardStyle];
        CGRect frame = tagView.frame;
        frame.origin.x = offset;
        offset+=frame.size.width + 4;
        tagView.frame = frame;
        [self.tagContainer addSubview:tagView];
    }
}

@end
