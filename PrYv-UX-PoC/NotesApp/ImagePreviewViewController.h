//
//  ImagePreviewViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/12/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@interface ImagePreviewViewController : UIViewController//BaseViewController

@property (nonatomic, weak) IBOutlet UITextView *descriptionText;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *contentImageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *descText;

@end
