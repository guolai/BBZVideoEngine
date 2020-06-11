//
//  BBZCompositonDirector.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZCompositonDirector.h"
#import "BBZSourceAction.h"
#import "BBZFilterAction.h"
#import "BBZOutputAction.h"
#import "BBZInputFilterAction.h"

@interface BBZCompositonDirector ()
//@property (nonatomic, strong) BBZFilterMixer *filterMixer;

// 当前区间
@property (nonatomic, strong) NSArray *actions;
//@property (nonatomic, assign) BOOL bLocked;
@property (nonatomic, assign) NSUInteger currentTimePoint;
@property (nonatomic, assign) NSUInteger currentIndex;
@end


@implementation BBZCompositonDirector

- (instancetype)init {
    if(self = [super init]) {
//        _filterMixer = [[BBZFilterMixer alloc] init];
        _currentIndex = 0;
    }
    return self;
}

#pragma mark - Schedule

- (void)updateWithTime:(CMTime)time{
//    //首次进入
//    if(self.currentTimePoint == 0 && ![self findNextTimePoint]) {
//        [self didReachEndTime];
//        return;
//    }
    //to do 需要进行时间换算，和误差处理
    NSTimeInterval realTimePoint = self.currentTimePoint/(BBZVideoDurationScale * 1.0);
    if(CMTimeGetSeconds(time) >= realTimePoint) {
        if(![self findNextTimePoint]) {
            [self didReachEndTime];
            return;
        } else {
            NSArray *actons = self.actions;
            self.actions = [self.segmentDelegate layerActionTreesBeforeTimePoint:self.currentTimePoint];
            for (BBZAction *action in self.actions) {
                [action lock];
            }
            for (BBZAction *action in actons) {
                [action unlock];
            }
        }
        if(self.actions.count == 0) {
            [self didReachEndTime];
            return;
        }
    }
    
    for (BBZAction *action in self.actions) {
        [action updateWithTime:time];
    }
    for (BBZAction *action in self.actions) {
        [action newFrameAtTime:time];
    }
    for (BBZAction *action in self.actions) {
        if([action isKindOfClass:[BBZInputFilterAction class]]) {
            [((BBZInputFilterAction *)action) processAVSourceAtTime:time];
        }
    }

}

- (void)didSeekToTime:(CMTime)time {
    
}

- (void)didReachEndTime {
    //到达结束两种情形 1.updateWithTime 2.读取资源失败并且接近尾声，
    //读取资源失败未接近尾声的时候可以通过纠错的方式来修正，比如返回一个黑帧或者返回上一帧画面(视频画面拉长或者视频将播放时长大于媒体时长，但是在action正常时常范围内)
    [self.segmentDelegate didReachEndTime];
    for (BBZAction *action in self.actions) {
       [action unlock];
    }
    self.currentIndex = 0;
    self.currentTimePoint = 0;
}

- (BOOL)findNextTimePoint {
    BOOL bFind = YES;
    self.currentIndex++;
    
    if(self.currentIndex >= self.timePointsArray.count) {
        bFind = NO;
        return bFind;
    }
    self.currentTimePoint = [[self.timePointsArray objectAtIndex:self.currentIndex] unsignedIntegerValue];
    return bFind;
}


@end
