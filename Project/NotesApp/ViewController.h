//
//  ViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PryvApiKit/PryvApiKit.h>
#import <PryvApiKit/PYWebLoginViewController.h>

@interface ViewController : UIViewController <PYWebLoginDelegate>

- (void)initSignIn;

@end
