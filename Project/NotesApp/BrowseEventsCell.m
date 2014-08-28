//
//  BrowseEventsCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseEventsCell.h"
#import "CellStyleModel.h"
#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"
#import "UserHistoryEntry.h"
#import <PryvApiKit/PYEventType.h>
#import <PryvApiKit/PYEventClass.h>
#import "TagContainer.h"

#define kScreenSize 320

@interface BrowseEventsCell ()

@property (nonatomic, strong) IBOutlet UILabel *streamBreadcrumbs;
//@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet TagContainer *tagContainer;
@property (nonatomic, weak) IBOutlet UILabel *lbHelp;
@property (nonatomic, strong) IBOutlet UILabel *symbolLabel;
@property (nonatomic, strong) IBOutlet UIView *pastille;
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
    self.streamBreadcrumbs.text = [event eventBreadcrumbs];
    [self.pastille setBackgroundColor:[[event stream] getColor]];
    
    NSString* symbol = [self symbolRepresentationForEventType:event.pyType];
    if (symbol) {
        self.symbolLabel.text = symbol;
        self.iconImageView.image = nil;
    } else {
        self.symbolLabel.text = @"";
        UIImage* iconImage = [UIImage imageNamed:[self imageNameForType:[event eventDataType]]];
        self.iconImageView.image = iconImage;
    }
    
    NSString *help = nil;
    switch ([event eventDataType]) {
        case EventDataTypeValueMeasure:
        {
            help = NSLocalizedString(@"AddEvent.AddMeasure", nil);
        }
            break;
        case EventDataTypeImage:
        {
            help = NSLocalizedString(@"AddEvent.AddPicture", nil);
        }
            break;
        case EventDataTypeNote:
        {
            help = NSLocalizedString(@"AddEvent.AddNote", nil);
        }
            break;
        default:
            break;
    }
    [self.lbHelp setText:help];
    [self.tagContainer updateWithTags:event.tags];
    
    //self.valueLabel.text = [self stringRepresentationForEventType:event.pyType];
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
            return @"icon_value";
        case EventDataTypeImage:
            return @"icon_photo";
        case EventDataTypeNote:
            return @"icon_note";
        default:
            break;
    }
    return @"icon_small_text_grey";
}

@end
