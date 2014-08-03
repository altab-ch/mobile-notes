//
//  TagsDetailCell.m
//  NotesApp
//
//  Created by Mathieu Knecht on 01.08.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "TagsDetailCell.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"
#import "EventDetailsViewController.h"

@interface TagsDetailCell () <JSTokenFieldDelegate>

@property (nonatomic, weak) IBOutlet JSTokenField *tokenField;

@end

@implementation TagsDetailCell

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
    [self initTags];
}

#pragma mark - JSTokenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    return NO;
}

- (void)tokenFieldWillBeginEditing:(JSTokenField *)tokenField
{
    
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField
{
    [self.tokenField updateTokensInTextField:self.tokenField.textField];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in self.tokenField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.event.tags = tokens;
}

- (void)initTags
{
    self.tokenField.delegate = self;
    for(NSString *tag in [self event].tags)
    {
        [self.tokenField addTokenWithTitle:tag representedObject:tag];
    }
}

- (void)tokenContainerDidChangeFrameNotification:(NSNotification*)note
{
    [self updateConstraints];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
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
