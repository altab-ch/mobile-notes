//
//  ImageViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 10.04.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "ImageViewController.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ImageViewController ()

@end

@implementation ImageViewController

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
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonTouched:)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGR];
    self.contentImageView.image = self.image;
    [self.contentImageView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationController.navigationBarHidden = YES;
    
}

-(void) viewDidAppear:(BOOL)animated
{
    if (IS_IPHONE_5){
        [self.contentImageView setFrame:CGRectMake(0, 0, 320.0, 568.0)];
    }else{
        [self.contentImageView setFrame:CGRectMake(0, 0, 320.0, 480.0)];
    }
    NSLog(@"view : %f, %f, %f, %f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
    NSLog(@"scrollview : %f, %f, %f, %f", self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.height, self.scrollView.frame.size.width);
    NSLog(@"scrollview : %f, %f, %f, %f", self.contentImageView.frame.origin.x, self.contentImageView.frame.origin.y, self.contentImageView.frame.size.height, self.contentImageView.frame.size.width);
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
    return self.contentImageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
