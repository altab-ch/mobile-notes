//
//  ImageViewController.h
//  NotesApp
//
//  Created by Mathieu Knecht on 10.04.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *contentImageView;
@property (nonatomic, strong) UIImage *image;

@end
