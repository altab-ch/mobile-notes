//
//  TagLabel.m
//  NotesApp
//
//  Created by Mathieu Knecht on 27.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "TagLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation TagLabel

-(id) initWithText:(NSString*)text
{
    self = [super init];
    if (self) {
        self.text = text;
        self.textColor = [UIColor groupTableViewBackgroundColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        self.layer.cornerRadius = 3;
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }
    return self;
}

@end
