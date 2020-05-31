//
//  BBZSchedule.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZVideoControl.h"



@protocol BBZScheduleObserver <NSObject>
@required
- (void)updateWithTime:(CMTime)time;
- (void)didSeekToTime:(CMTime)time;
//@optional
//- (void)didReachEndTime;
@end

@interface BBZSchedule : NSObject
@property (nonatomic, assign, readonly) BOOL bPaused;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) float rate;
@property (nonatomic, assign) NSInteger preferredFramesPerSecond; //最好是30, 24, 60这样的数值
@property (nonatomic, weak) id<BBZScheduleObserver> observer;
@property (nonatomic, assign, readonly) CMTime targetFrameDuration;
@property (nonatomic, assign, readonly) CMTime minimumFrameDuration;

- (instancetype)initWithMode:(BBZEngineScheduleMode)mode;
+ (instancetype)scheduleWithMode:(BBZEngineScheduleMode)mode;

- (void)setTimelineRate:(float)rate;
- (void)startTimeline;
- (void)pauseTimeline;
- (void)stopTimeline;
- (void)seekTimelineToTime:(CMTime)time;
- (void)increaseTime;

@end

