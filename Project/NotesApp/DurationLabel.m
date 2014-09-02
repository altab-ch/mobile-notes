//
//  DurationLabel.m
//  NotesApp
//
//  Created by Mathieu Knecht on 28.07.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "DurationLabel.h"

@interface DurationLabel ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *updateUILock;

@end

@implementation DurationLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.updateUILock = [[NSLock alloc] init];
        self.isHeader = false;
    }
    return self;
}

-(void) setEndDate:(NSDate *)endDate
{
    _endDate = endDate;
    [self updateDateUI:endDate];
}

-(void) start
{
    [self stop];
    self.textColor = [UIColor redColor];
    [self updateDateUI:[NSDate date]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void) stop
{
    self.textColor = [UIColor grayColor];
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    //self.endDate = nil;
}

-(void) update
{
    if (self.endDate)
        [self updateDateUI:self.endDate];
    else
        [self updateDateUI:[NSDate date]];
}

-(void) updateDateUI:(NSDate*)date
{
    [self.updateUILock lock];
    
    NSString *duration = [[NotesAppController sharedInstance] durationFromDate:self.event.eventDate toDate:date];
    
    if (self.isHeader)
        [self setText:[NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Detail.duration", nil), duration]];
    else
        [self setText:duration];
    
    [self.updateUILock unlock];
}

-(void) dealloc
{
    [self.timer invalidate];
}

@end
