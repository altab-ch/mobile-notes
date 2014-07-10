//
//  BaseWithMenuViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseWithMenuViewController.h"
#import "TopMenuCell.h"

#define kCellHeight 56

@interface BaseWithMenuViewController ()

@property (nonatomic, strong) NSArray *topMenuCellImages;

- (void)menuButtonTouched:(id)sender;

@end

@implementation BaseWithMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.enabled = YES;
	
    //self.navigationItem.rightBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_add"] target:self action:@selector(menuButtonTouched:)];
    
    self.topMenuCellImages = @[@"icon_small_text",
                               @"icon_small_lenght",
                               @"icon_small_photo"];
    
    CGFloat tableHeight = self.view.bounds.size.height;
    self.menuOpen = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.view bringSubviewToFront:self.menuTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topMenuCellImages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MenuCellIdentifier = @"MenuCell_ID";
    TopMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:MenuCellIdentifier];
    if(!cell)
    {
        cell = (TopMenuCell*)[[TopMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifier];
    }
    UIImage *img = [UIImage imageNamed:[self.topMenuCellImages objectAtIndex:indexPath.row]];
    cell.iconImageView.image = img;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(UIButton*)self.navigationItem.rightBarButtonItem.customView setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [self topMenuDidSelectOptionAtIndex:indexPath.row];
}

#pragma mark - Actions

- (void)menuButtonTouched:(id)sender
{
    [self setMenuVisible:(!self.isMenuOpen && self.enabled) animated:YES withCompletionBlock:nil];
}

- (void)updateTopButtonIsInActiveState:(BOOL)isActive
{
    [(UIButton*)self.navigationItem.rightBarButtonItem.customView setImage:[UIImage imageNamed:isActive ? @"icon_add_active" : @"icon_add"] forState:UIControlStateNormal];
}

- (void)setMenuVisible:(BOOL)visible animated:(BOOL)animated withCompletionBlock:(void (^)(void))completionBlock
{
    [self topMenuVisibilityWillChange];
    [self updateTopButtonIsInActiveState:visible];
    //CGFloat pointY = visible ? 0 : -self.menuTableView.bounds.size.height;
    if(!visible)
    {
        self.menuOpen = NO;
        self.title = NSLocalizedString(@"BrowserViewController.Title", nil);
        [self topMenuVisibilityDidChange];
        //self.menuTableView.userInteractionEnabled = NO;
    }
    NSInteger option = visible ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | option animations:^{
        //[self.menuTableView setY:pointY];
    } completion:^(BOOL finished) {
        if(visible)
        {
            self.menuOpen = YES;
            self.title = NSLocalizedString(@"BrowserViewController.TitleMenuOpen", nil);
            [self topMenuVisibilityDidChange];
            //self.menuTableView.userInteractionEnabled = YES;
        }
        if(completionBlock)
        {
            completionBlock();
        }
    }];
    
}

- (void)topMenuDidSelectOptionAtIndex:(NSInteger)index
{
    
}

- (void)topMenuVisibilityWillChange
{
    
}

- (void)topMenuVisibilityDidChange
{
    
}

@end
