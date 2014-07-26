//
//  DetailsBottomButtonsContainer.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/30/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DetailsBottomButtonsContainer.h"

@implementation DetailsBottomButtonsContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // hide
        self.shareButton.hidden = YES;
        
    }
    return self;
}

- (IBAction)shareButtonTouched:(id)sender
{
    if(self.shareButtonTouchHandler)
    {
        self.shareButtonTouchHandler(sender);
    }
}

- (IBAction)deleteButtonTouched:(id)sender
{
    if(self.deleteButtonTouchHandler)
    {
        self.deleteButtonTouchHandler(sender);
    }
}

@end
