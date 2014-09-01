//
//  InboardingViewController.m
//  NotesApp
//
//  Created by Mathieu Knecht on 25.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "InboardingViewController.h"

@interface InboardingViewController ()

@end

@implementation InboardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        [_webView loadHTMLString:htmlString baseURL:nil];
        [self.view addSubview:_webView];
    }
    return self;
}

+ (id)sharedInstance {
    static InboardingViewController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle: NSLocalizedString(@"inboarding.back", nil)
                                   style: UIBarButtonItemStyleBordered
                                   target:self action: @selector(btDoneTouched)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_webView setFrame:self.view.bounds];
}

-(void) btDoneTouched
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_webView reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
