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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenContainerDidChangeFrameNotification:)
                                                     name:JSTokenFieldFrameDidChangeNotification
                                                   object:nil];
    }
    return self;
}

-(void) updateWithEvent:(PYEvent*)event
{
    [super updateWithEvent:event];
    [self initTags];
}

-(void) didSelectCell:(UIViewController *)controller
{
    [self.tokenField.textField becomeFirstResponder];
}

#pragma mark - JSTokenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    return NO;
}

- (void)tokenFieldWillBeginEditing:(JSTokenField *)tokenField
{
    [self.delegate closePickers:NO];
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
    [self.delegate detailShouldUpdateEvent];
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
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y+20) animated:YES];
}

-(void) setIsInEditMode:(BOOL)isInEditMode
{
    [super setIsInEditMode:isInEditMode];
    [self.tokenField setUserInteractionEnabled:isInEditMode];
    [self.tokenField resignFirstResponder];
}

#pragma mark - Border

-(BOOL) shouldUpdateBorder
{
    return YES;
}

-(CGFloat) getHeight
{
    return self.tokenField.frame.size.height + 38;
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
