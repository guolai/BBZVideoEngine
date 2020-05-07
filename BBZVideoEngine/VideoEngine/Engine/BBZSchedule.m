//
//  BBZSchedule.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZSchedule.h"

@interface BBZSchedule ()
@property (nonatomic, assign) BBZEngineScheduleMode mode;
@property (nonatomic, assign, readwrite) BOOL bPaused;
@property (nonatomic, assign, readwrite) NSTimeInterval currentTime;
@property (nonatomic, assign, readwrite) float rate;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign, readwrite) CMTime targetFrameDuration;
@property (nonatomic, assign, readwrite) CMTime minimumFrameDuration;
@end

@implementation BBZSchedule

- (instancetype)initWithMode:(BBZEngineScheduleMode)mode {
    if(self = [super init]) {
        _mode = mode;
        _rate = 1.0;
        _bPaused = YES;
        _currentTime = 0;
        _preferredFramesPerSecond = 30;
        _targetFrameDuration = CMTimeMake(BBZVideoDurationScale/_preferredFramesPerSecond, BBZVideoDurationScale);
        _minimumFrameDuration = CMTimeMake(BBZVideoDurationScale * 2 /_preferredFramesPerSecond, BBZVideoDurationScale);
    }
    return self;
}

+ (instancetype)scheduleWithMode:(BBZEngineScheduleMode)mode {
    BBZSchedule *schedule = [[BBZSchedule alloc] initWithMode:mode];
    return schedule;
}


- (void)onTimer:(CADisplayLink *)displayLink {
    NSTimeInterval now = CFAbsoluteTimeGetCurrent();
    NSTimeInterval deltaTime = (now - self.lastTime) * self.rate;
    self.currentTime = self.currentTime + deltaTime;
    self.lastTime = now;

    BBZINFO(@" currentTime = %.3f", self.currentTime);
    [self.observer updateWithTime:self.currentTime];
}

- (void)updateFrameIntervalForDisplayLink {
    
    if (self.displayLink != nil && self.mode != BBZEngineScheduleModeExport) {
        if (@available(iOS 10.0, *)) {
            [self.displayLink setPreferredFramesPerSecond:self.preferredFramesPerSecond];
        } else {
            self.displayLink.frameInterval = self.preferredFramesPerSecond;
        }
    }
    self.targetFrameDuration = CMTimeMake(BBZVideoDurationScale/_preferredFramesPerSecond, BBZVideoDurationScale);
    self.minimumFrameDuration = CMTimeMake(BBZVideoDurationScale * 2 /_preferredFramesPerSecond, BBZVideoDurationScale);
}


- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _preferredFramesPerSecond = preferredFramesPerSecond;
    [self updateFrameIntervalForDisplayLink];
}

- (void)setTimelineRate:(float)rate {
    self.rate = rate;
}

- (void)startTimeline {
    self.bPaused = NO;
    if(self.mode == BBZEngineScheduleModeExport) {
        NSTimeInterval now = CFAbsoluteTimeGetCurrent();
        NSTimeInterval deltaTime = (now - self.lastTime) * self.rate;
        self.currentTime = self.currentTime + deltaTime;
        self.lastTime = now;
    } else {
        if (self.displayLink == nil) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimer:)];
            [self updateFrameIntervalForDisplayLink];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            self.displayLink.paused = NO;
        }
    }
    
    BBZINFO(@"timeline start");
}

- (void)setBPaused:(BOOL)bPaused {
    _bPaused = bPaused;
    self.displayLink.paused = _bPaused;
    if(_bPaused) {
        NSTimeInterval now = CFAbsoluteTimeGetCurrent();
        NSTimeInterval deltaTime = (now - self.lastTime) * self.rate;
        self.currentTime = self.currentTime + deltaTime;
    } else {
        self.lastTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)pauseTimeline {
    self.bPaused = YES;
    BBZINFO(@"pauseTimeline");
}

- (void)stopTimeline {
    self.bPaused = YES;
    if (self.displayLink != nil) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    BBZINFO(@"resetTimeline");
}

- (void)seekTimelineToTime:(NSTimeInterval)time {
    self.currentTime = time;
    self.lastTime = CFAbsoluteTimeGetCurrent();
}

- (void)increaseTime {
    self.currentTime += CMTimeGetSeconds(self.targetFrameDuration);
    [self.observer updateWithTime:self.currentTime];
}

@end
