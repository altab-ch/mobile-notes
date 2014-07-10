//
//  PhotoNoteViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PhotoNoteViewController.h"
#import "UIImage+PrYv.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#define kSaveImageSegue_ID @"SaveImageSegue_ID"

@interface PhotoNoteViewController ()

@end

@implementation PhotoNoteViewController

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
	
    //[self addCustomBackButton];
    [self setupImagePicker];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*if(!self.isBeingDismissed)
    {
        [self presentViewController:self animated:NO completion:nil];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupImagePicker
{
    /*if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&  self.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }*/
    
    if(self.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        self.showsCameraControls = YES;
    }
    
}

/*- (UIImage*)scaledImageForImage:(UIImage*)image
{
    CGSize newSize = image.size;
    CGFloat maxSide = MAX(newSize.width, newSize.height);
    CGFloat ratio = maxSide / 1024.0f;
    newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
    return [image imageScaledToSize:newSize];
}*/

@end
