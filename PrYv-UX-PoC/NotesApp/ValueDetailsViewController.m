//
//  ValueDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ValueDetailsViewController.h"

@interface ValueDetailsViewController ()

@end

@implementation ValueDetailsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEventDetails
{
    NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
    if([components count] > 1)
    {
        NSString *value = [NSString stringWithFormat:@"%@ %@",[self.event.eventContent description],[components objectAtIndex:1]];
        self.eventValueLabel.text = value;
    }
    self.eventDescriptionLabel.text = self.event.eventDescription;
}

@end
