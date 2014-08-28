//
//  TagContainer.m
//  NotesApp
//
//  Created by Mathieu Knecht on 28.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "TagContainer.h"
#import "TagLabel.h"

@interface TagContainer()

@property (nonatomic, strong) NSArray *tags;

@end

@implementation TagContainer

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = true;
    }
    return self;
}


-(void) updateWithTags:(NSArray*)tags
{
    self.tags = tags;
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){[obj removeFromSuperview];}];
    
    int offset = 0;
    for(NSString *tag in self.tags)
    {
        TagLabel *tagLabel = [[TagLabel alloc] initWithText:tag];
        CGRect frame = tagLabel.frame;
        frame.origin.x = offset;
        offset+=frame.size.width + 4;
        tagLabel.frame = frame;
        [self addSubview:tagLabel];
        if (offset >= self.frame.size.width) return;        
    }
}

@end
