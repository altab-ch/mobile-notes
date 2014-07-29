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

@end

@implementation DurationLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) start
{
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateDate) userInfo:nil repeats:YES];
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
    NSInteger duration = (NSInteger)[date timeIntervalSinceDate:_eventDate];
    NSInteger seconds = duration % 60;
    NSInteger minutes = (duration / 60) % 60;
    NSInteger hours = (duration / 3600);
    NSString* time;
    if (hours!=0)
        time=[NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    else if (hours==0)
        time=[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    else if (minutes==0)
        time=[NSString stringWithFormat:@"%02ld", (long)seconds];
    
    [self setText:[NSString stringWithFormat:@"%@", time]];
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
