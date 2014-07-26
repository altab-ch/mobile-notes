//
//  InboardingViewController.h
//  NotesApp
//
//  Created by Mathieu Knecht on 25.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboardingViewController : UIViewController

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSString *btBackLocalTag;

+ (id)sharedInstance;

@end
