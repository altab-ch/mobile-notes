//
//  PhotoDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PhotoDetailCell.h"
#import "PYEvent+Helper.h"

@interface PhotoDetailCell ()

@property (nonatomic, weak) IBOutlet UIImageView *picture_ImageView;

@end

@implementation PhotoDetailCell

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
    if(self.picture_ImageView.image)
    {
        return;
    }
    [event preview:^(UIImage *img) {
        if(self.picture_ImageView.image) return;
        self.picture_ImageView.image = img;
    } failure:nil];
    
    [event firstAttachmentAsImage:^(UIImage *image) {
        self.picture_ImageView.image = image;
    } errorHandler:nil];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return NO;
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
