//
//  BBZVideoEngine.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/27.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoEngine.h"
#import "BBZSchedule.h"
#import "BBZFilterLayer.h"
#import "BBZFilterMixer.h"
#import "BBZVideoFilterLayer.h"
#import "BBZAudioFilterLayer.h"
#import "BBZEffetFilterLayer.h"
#import "BBZMaskFilterLayer.h"
#import "BBZOutputFilterLayer.h"
#import "BBZTransitionFilterLayer.h"


typedef NS_ENUM(NSInteger, BBZFilterLayerType) {
    BBZFilterLayerTypeVideo,//视频 图片 背景图 拼接
    BBZFilterLayerTypeAudio,//音频
    BBZFilterLayerTypeTransition,//转场
    BBZFilterLayerTypeEffect,//特效
    BBZFilterLayerTypeMask,//水印
    BBZFilterLayerTypeOutput,//输出
    BBZFilterLayerTypeMax,
};


@interface BBZVideoEngine () <BBZScheduleObserver>
@property (nonatomic, strong) BBZVideoModel *videoModel;
@property (nonatomic, strong) BBZEngineContext *context;
@property (nonatomic, strong) NSString *outputFile;

@property (nonatomic, strong) BBZSchedule *schedule;
//@property (nonatomic, strong) BBZVideoModel *videoModel;
@property (nonatomic, strong) BBZFilterMixer *filterMixer;
@property (nonatomic, strong) NSMutableDictionary *filterLayers;

@end


@implementation BBZVideoEngine

- (instancetype)initWithModel:(BBZVideoModel *)videoModel
                context:(BBZEngineContext *)context {
    if(self = [super init]) {
        _videoModel = videoModel;
        _context = context;
        [self buildVideoEngine];
        [self buildFilterLayers];
    }
    return self;
}


+ (instancetype)videoEngineWithModel:(BBZVideoModel *)model
                             context:(BBZEngineContext *)context
                          outputFile:(NSString *)outputFile {
    BBZVideoEngine *videoEngine = [[BBZVideoEngine alloc] initWithModel:model context:context];
    videoEngine.outputFile = outputFile;
    return videoEngine;
}

#pragma mark - Private

- (void)buildFilterLayers {
    self.filterLayers = [NSMutableDictionary dictionaryWithCapacity:BBZFilterLayerTypeMax];
    
    
    BBZVideoFilterLayer *videolayer = [[BBZVideoFilterLayer alloc] initWithModel:self.videoModel context:self.context];
        self.filterLayers[@(BBZFilterLayerTypeVideo)] = videolayer;
    BBZAudioFilterLayer *audioLayer = [[BBZAudioFilterLayer alloc] initWithModel:self.videoModel context:self.context];
    self.filterLayers[@(BBZFilterLayerTypeAudio)] = audioLayer;
    
    BBZTransitionFilterLayer *transitionLayer = [[BBZTransitionFilterLayer alloc] initWithModel:self.videoModel context:self.context];
    self.filterLayers[@(BBZFilterLayerTypeTransition)] = transitionLayer;
    
    BBZEffetFilterLayer *effectLayer = [[BBZEffetFilterLayer alloc] initWithModel:self.videoModel context:self.context];
    self.filterLayers[@(BBZFilterLayerTypeEffect)] = effectLayer;
    
    BBZMaskFilterLayer *maskLayer = [[BBZMaskFilterLayer alloc] initWithModel:self.videoModel context:self.context];
    self.filterLayers[@(BBZFilterLayerTypeMask)] = maskLayer;
    
    BBZOutputFilterLayer *outputLayer = [[BBZOutputFilterLayer alloc] initWithModel:self.videoModel context:self.context];
    self.filterLayers[@(BBZFilterLayerTypeOutput)] = outputLayer;
    
    BBZActionBuilderResult *builerResult = nil;
    for (int i = BBZFilterLayerTypeVideo; i < BBZFilterLayerTypeMax; i++) {
        BBZFilterLayer *layer = self.filterLayers[@(i)];
        if(i == BBZFilterLayerTypeVideo || i == BBZFilterLayerTypeTransition) {
            builerResult = [layer buildTimelineNodes:builerResult];
        } else {
            [layer buildTimelineNodes:builerResult];
        }
    }
}

- (void)buildVideoEngine {
    self.schedule = [BBZSchedule scheduleWithMode:self.context.scheduleMode];
    self.schedule.observer = self;
    self.filterMixer = [[BBZFilterMixer alloc] init];
}

- (BOOL)start {
   
    return YES;
}

- (BOOL)pause {
    return YES;
}

- (BOOL)cancel {
    return YES;
}


#pragma mark - Schedule

- (void)updateWithTime:(NSTimeInterval)time{
    //to do check time 是否超出
}

- (void)didSeekToTime:(NSTimeInterval)time{
    
}

- (void)didReachEndTime{
    //到达结束两种情形 1.updateWithTime 2.读取资源失败并且接近尾声，
    //读取资源失败未接近尾声的时候可以通过纠错的方式来修正，比如返回一个黑帧或者返回上一帧画面(视频画面拉长或者视频将播放时长大于媒体时长，但是在action正常时常范围内)
}

@end
