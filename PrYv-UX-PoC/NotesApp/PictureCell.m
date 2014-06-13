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
#import "StreamAccessory.h"
#import "PYStream+Helper.h"

@interface PictureCell ()

@property (nonatomic, copy) NSString *currentEventId;
@property (nonatomic, strong) NSDate *startLoadTime;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIImage *currentImage;

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
    self.currentImage = nil;
}


- (void)updateWithImage:(UIImage*)img andEventId:(NSString*)clientId animated:(BOOL)animated
{
    
    
    // maybe called sevral times while the picture was loading.
    // so the cell may have been reused for another event or picture already loaded by a previous call
    if([clientId isEqualToString:self.currentEventId] && self.currentImage)
    {
        return;
    }
    self.currentImage = img;
    
    animated = NO;
    
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
                [self.pictureView setImage:self.currentImage];
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
            [self.pictureView setImage:self.currentImage];
            self.loadingIndicator.hidden = YES;
            [self.loadingIndicator stopAnimating];
            
        }
        
    });
    
}

- (void)updateWithEvent:(PYEvent *)event
{
    [super updateWithEvent:event];
    
    for (UIView *vi in self.subviews) {
        for (UIView *vi2 in vi.subviews) {
            if ([vi2 isKindOfClass:[StreamAccessory class]]) {
                [vi2 removeFromSuperview];
            }
        }
    }
    
    StreamAccessory *st = [[StreamAccessory alloc] initText:[event eventBreadcrumbs] color:[[event stream] getColor]];
    [self addSubview:st];
    
    NSDate *d = [event eventDate];
    StreamAccessory *date = [[StreamAccessory alloc] initText:[self.dateFormatter stringFromDate:d] color:nil];
    [self addSubview:date];
    
    self.startLoadTime = [NSDate date];
    self.currentEventId = event.clientId;
    
    // anyway try to load the first attachement
    [event firstAttachmentAsImage:^(UIImage *image) {
        [self updateWithImage:image andEventId:event.clientId animated:NO];
    } errorHandler:^(NSError *error) {
        // then the preview
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingIndicator.hidden = NO;
            [self.loadingIndicator startAnimating];
            [event preview:^(UIImage *image) {
                
                [self updateWithImage:image andEventId:event.clientId animated:[PictureCell shouldAnimateImagePresentationForStartLoadTime:self.startLoadTime]];
                
            } failure:^(NSError *error) {
                NSLog(@"*1432 Failed loading preview for event %@ \n %@", error, event);
                [self updateWithImage:nil andEventId:event.clientId animated:NO];
                
            }];
        });
        
        
    
    }];
    
    
}

// animate only if loading took more than...
+ (BOOL)shouldAnimateImagePresentationForStartLoadTime:(NSDate*)startLoadTime
{
    return fabs([startLoadTime timeIntervalSinceNow]) > 0.2f;
}

@end
