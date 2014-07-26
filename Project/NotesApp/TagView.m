//
//  TagView.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/15/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "TagView.h"
#import <QuartzCore/QuartzCore.h>

#define kTagHeight 16.0
#define kTagFontSize 11.0

@interface TagView ()

@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic) TagViewStyle style;

+ (UILabel*)createTagLabelWithStyle:(TagViewStyle)style;

@end

@implementation TagView

- (id)initWithText:(NSString *)tagText andStyle:(TagViewStyle)style
{
    self = [super init];
    if(self)
    {
        self.style = style;
        self.tagLabel = [TagView createTagLabelWithStyle:style];
        self.tagLabel.text = tagText;
        CGSize labelSize = [tagText sizeWithFont:self.tagLabel.font];
        self.tagLabel.frame = CGRectMake(4, 0, labelSize.width, kTagHeight);
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width + 8, kTagHeight)];
        if(style == TagViewStandardStyle)
        {
            self.backgroundView.backgroundColor = [UIColor whiteColor];
            self.backgroundView.layer.borderColor = [UIColor colorWithRed:169.0f/255.0f green:169.0f/255.0f blue:169.0f/255.0f alpha:1].CGColor;
            self.backgroundView.layer.borderWidth = 1.0f;
            self.backgroundView.layer.cornerRadius = 5;
            self.backgroundView.layer.masksToBounds = YES;
            
        }
        else
        {
            self.backgroundView.backgroundColor = [UIColor whiteColor];
            self.backgroundView.layer.borderColor = [UIColor colorWithRed:169.0f/255.0f green:169.0f/255.0f blue:169.0f/255.0f alpha:1].CGColor;
            self.backgroundView.layer.borderWidth = 1.0f;
            self.backgroundView.layer.cornerRadius = 5;
            self.backgroundView.layer.masksToBounds = YES;
        }
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        [self addSubview:self.tagLabel];
        self.frame = self.backgroundView.frame;
    }
    return self;
}

+ (UILabel*)createTagLabelWithStyle:(TagViewStyle)style
{
    UILabel *tagLabel = [[UILabel alloc] init];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    [tagLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:kTagFontSize]];
    if(style == TagViewStandardStyle)
    {
        [tagLabel setTextColor:[UIColor colorWithRed:169.0f/255.0f green:169.0f/255.0f blue:169.0f/255.0f alpha:1]];
    }
    else
    {
        [tagLabel setTextColor:[UIColor colorWithRed:169.0f/255.0f green:169.0f/255.0f blue:169.0f/255.0f alpha:1]];
    }
    [tagLabel setAlpha:1];
    return tagLabel;
}

@end
