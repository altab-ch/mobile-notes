//
//  TagView.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/15/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TagViewStyle)
{
    TagViewStandardStyle,
    TagViewTransparentStyle
};

@interface TagView : UIView

- (id)initWithText:(NSString*)tagText andStyle:(TagViewStyle)style;

@end
