//
//  LineCell.h
//  NotesApp
//
//  Created by Mathieu Knecht on 15.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseCell.h"

typedef enum {
    kBarGraphStyle = 0,
    kLineGraphStyle,
    kAreaGraphStyle
}GraphStyle;

@interface LineCell : BrowseCell

@property(nonatomic) GraphStyle graphStyle;

@end
