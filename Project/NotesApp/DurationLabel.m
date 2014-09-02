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


-(void) start
{
    if (self.timer) return;

    self.textColor = [UIColor redColor];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void) stop
{
   self.textColor = [UIColor grayColor];
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void) update
{
    [self.updateUILock lock];
    
    if (self.event.duration == 0) {
        [self setText:@""];
        [self.updateUILock unlock];
        return;
    }
    
    NSString *duration;
    if (self.event.isRunning) {
        [self start];
        duration = [NotesAppController durationFromDate:self.event.eventDate toDate:[NSDate date]];
    } else {
        [self stop];
        duration = [NotesAppController durationFormatter:self.event.duration];
    }
    
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
