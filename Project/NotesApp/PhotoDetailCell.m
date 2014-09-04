//
//  PhotoDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PhotoDetailCell.h"
#import "PYEvent+Helper.h"
#import "ImageViewController.h"

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
        [self setFrame:CGRectMake(0, 0, 320, [self getHeight])];
        [self layoutIfNeeded];
    } failure:nil];
    
    [event firstAttachmentAsImage:^(UIImage *image) {
        self.picture_ImageView.image = image;
        [self setFrame:CGRectMake(0, 0, 320, [self getHeight])];
        [self layoutIfNeeded];
    } errorHandler:nil];
}

-(void) didSelectCell:(UIViewController*)controller
{
    ImageViewController* imvc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ImagePreviewViewController_ID"];
    [imvc setImage:self.picture_ImageView.image];
    [controller presentViewController:imvc animated:YES completion:nil];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return NO;
}

-(CGFloat) getHeight
{
    CGFloat height = 44;
    UIImage* image = self.picture_ImageView.image;
    if(image)
    {
        CGFloat scaleFactor = 320 / image.size.width;
        height = image.size.height * scaleFactor;
    }
    return height;
    //return 160;
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
