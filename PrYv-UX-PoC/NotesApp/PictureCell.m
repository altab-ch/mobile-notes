//
//  PictureCell.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PictureCell.h"
#import "UIImage+PrYv.h"
#import <PryvApiKit/PYEvent+Utils.h>

@interface PictureCell ()

@property (nonatomic, copy) NSString *currentEventId;
@property (nonatomic, strong) NSDate *startLoadTime;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation PictureCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.pictureView.image = nil;
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}


- (void)updateWithImage:(UIImage*)img andEventId:(NSString*)eventId animated:(BOOL)animated
{
    if(![eventId isEqualToString:self.currentEventId] && self.pictureView.image)
    {
        return;
    }
    CGSize newSize = img.size;
    CGFloat maxSide = MAX(newSize.width, newSize.height);
    CGFloat ratio = maxSide / [self pictureView].bounds.size.width;
    newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
    img = [img imageScaledToSize:newSize];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(animated)
        {
            [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
                [self.pictureView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.pictureView setImage:img];
                [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.pictureView setAlpha:1.0f];
                    self.loadingIndicator.hidden = YES;
                    [self.loadingIndicator stopAnimating];
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
        else
        {
            [self.pictureView setAlpha:1.0f];
            [self.pictureView setImage:img];
            self.loadingIndicator.hidden = YES;
            [self.loadingIndicator stopAnimating];
        }
        
    });
    
}

- (void)updateWithEvent:(PYEvent *)event
{
    [super updateWithEvent:event];
    self.startLoadTime = [NSDate date];
    self.currentEventId = event.eventId;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([event hasFirstAttachmentFileDataInMemory]) {
            [event firstAttachmentAsImage:^(UIImage *image) {
                [self updateWithImage:image andEventId:event.eventId animated:[PictureCell shouldAnimateImagePresentationForStartLoadTime:self.startLoadTime]];
            } errorHandler:nil];
        } else {
            [event preview:^(UIImage *image) {
                
                [self updateWithImage:image andEventId:event.eventId animated:[PictureCell shouldAnimateImagePresentationForStartLoadTime:self.startLoadTime]];
            } failure:^(NSError *error) {
                NSLog(@"*1432 Failed loading preview for event %@ \n %@", error, event);
            }];
        }
    });
}

+ (BOOL)shouldAnimateImagePresentationForStartLoadTime:(NSDate*)startLoadTime
{
    return fabs([startLoadTime timeIntervalSinceNow]) > 0.2f;
}

@end
