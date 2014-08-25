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
    }
    return self;
}

-(void) start
{
    [self updateDateUI:[NSDate date]];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateDate) userInfo:nil repeats:YES];
}

-(void) stop
{
    if (_timer) [_timer invalidate];
}

-(void) setEndDate:(NSDate*)endDate
{
    [self updateDateUI:endDate];
}

-(void) updateDate
{
    [self updateDateUI:[NSDate date]];
}

-(void) updateDateUI:(NSDate*)date
{
    [self.updateUILock lock];
    NSInteger duration = (NSInteger)[date timeIntervalSinceDate:self.eventDate];
    NSInteger seconds = duration % 60;
    NSInteger minutes = (duration / 60) % 60;
    NSInteger hours = (duration / 3600);
    NSString* time;
    if (hours >= 48)
        time=[NSString stringWithFormat:@"%d %@s", hours/24, NSLocalizedString(@"day", nil)];
    else if (hours >= 24)
        time=[NSString stringWithFormat:@"%d %@", hours/24, NSLocalizedString(@"day", nil)];
    else if (hours>0)
        time=[NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    else if (hours==0)
        time=[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    else if (minutes==0)
        time=[NSString stringWithFormat:@"%02ld", (long)seconds];
    
    [self setText:[NSString stringWithFormat:@"%@", time]];
    [self.updateUILock unlock];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
