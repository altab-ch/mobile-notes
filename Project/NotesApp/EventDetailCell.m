//
//  EventDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 11.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EventDetailCell.h"
#import "PYEvent+Helper.h"
#import "PhotoDetailCell.h"
#import "NumericDetailCell.h"
#import "NoteDetailCell.h"

@interface EventDetailCell ()

@property (nonatomic, strong) BaseDetailCell* eventCell;

@end

@implementation EventDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) updateWithEvent:(PYEvent *)event
{
    [super updateWithEvent:event];
    EventDataType type = [event eventDataType];
    switch (type) {
        case EventDataTypeImage:
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PhotoDetailCell" owner:self options:nil];
            self.eventCell = (PhotoDetailCell *)[nib objectAtIndex:0];
            [(PhotoDetailCell *)self.eventCell setEventDelegate:self];
        }
            break;
            
        case EventDataTypeValueMeasure:
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NumericDetailCell" owner:self options:nil];
            self.eventCell = (NumericDetailCell *)[nib objectAtIndex:0];
            [(NumericDetailCell *)self.eventCell setEventDelegate:self];
        }
            break;
            
        case EventDataTypeNote:
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NoteDetailCell" owner:self options:nil];
            self.eventCell = (NoteDetailCell *)[nib objectAtIndex:0];
            [(NoteDetailCell *)self.eventCell setEventDelegate:self];
        }
            break;
            
        default:
            break;
    }
    [self.eventCell updateWithEvent:event];
    [self.eventCell setDelegate:self.delegate];
    [self.contentView addSubview:self.eventCell.contentView];
    
}

-(void) didSelectCell:(UIViewController*)controller
{
    [self.eventCell didSelectCell:controller];
}

-(void) updateTableview
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [self.eventCell setIsInEditMode:isInEditMode];
}

-(CGFloat) getHeight
{
    return self.eventCell.getHeight;
}

@end
