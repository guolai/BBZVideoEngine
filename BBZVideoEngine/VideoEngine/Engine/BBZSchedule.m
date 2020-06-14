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
        _targetFrameDuration = CMTimeMake(BBZScheduleTimeScale/_preferredFramesPerSecond, BBZScheduleTimeScale);
        _minimumFrameDuration = CMTimeMake(BBZScheduleTimeScale * 2 /_preferredFramesPerSecond, BBZScheduleTimeScale);
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
    CMTime tmpTime = CMTimeMake(self.currentTime * BBZScheduleTimeScale, BBZScheduleTimeScale);
//    BBZINFO(@" currentTime = %.4f,%.4f", self.currentTime, CMTimeGetSeconds(tmpTime));
    [self.observer updateWithTime:tmpTime];
}

- (void)updateFrameIntervalForDisplayLink {
    
    if (self.displayLink != nil && self.mode != BBZEngineScheduleModeExport) {
        if (@available(iOS 10.0, *)) {
            [self.displayLink setPreferredFramesPerSecond:self.preferredFramesPerSecond];
        } else {
            self.displayLink.frameInterval = self.preferredFramesPerSecond;
        }
    }
    self.targetFrameDuration = CMTimeMake(BBZScheduleTimeScale/_preferredFramesPerSecond, BBZScheduleTimeScale);
    self.minimumFrameDuration = CMTimeMake(BBZScheduleTimeScale * 2 /_preferredFramesPerSecond, BBZScheduleTimeScale);
}


- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _preferredFramesPerSecond = preferredFramesPerSecond;
    BBZINFO(@"schedule  FramesPerSecond %zd", preferredFramesPerSecond);
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
        CMTime tmpTime = CMTimeMake(self.currentTime * BBZScheduleTimeScale, BBZScheduleTimeScale);
        BBZINFO(@" currentTime = %.4f,%.4f", self.currentTime, CMTimeGetSeconds(tmpTime));
        [self.observer updateWithTime:tmpTime];
    } else {
        if (self.displayLink == nil) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimer:)];
            [self updateFrameIntervalForDisplayLink];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            self.displayLink.paused = NO;
        }
    }
    
    BBZINFO(@"BBZSchedule startTimeline");
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
    BBZINFO(@"BBZSchedule pauseTimeline");
}

- (void)stopTimeline {
    self.bPaused = YES;
    if (self.displayLink != nil) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    BBZINFO(@"BBZSchedule resetTimeline");
}

- (void)seekTimelineToTime:(CMTime)time {
    self.currentTime = CMTimeGetSeconds(time);
    self.lastTime = CFAbsoluteTimeGetCurrent();
}

- (void)increaseTime {
    self.currentTime += CMTimeGetSeconds(self.targetFrameDuration);
    CMTime tmpTime = CMTimeMake(self.currentTime * BBZScheduleTimeScale, BBZScheduleTimeScale);
//    BBZINFO(@" currentTime = %.4f,%.4f", self.currentTime, CMTimeGetSeconds(tmpTime));
    [self.observer updateWithTime:tmpTime];
}

@end
