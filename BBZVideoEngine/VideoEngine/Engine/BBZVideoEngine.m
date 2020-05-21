//
//  BBZVideoEngine.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/27.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoEngine.h"
#import "BBZCompositonDirector.h"
#import "BBZFilterLayer.h"
#import "BBZFilterMixer.h"
#import "BBZVideoFilterLayer.h"
#import "BBZAudioFilterLayer.h"
#import "BBZEffetFilterLayer.h"
#import "BBZMaskFilterLayer.h"
#import "BBZOutputFilterLayer.h"
#import "BBZTransitionFilterLayer.h"
#import "BBZQueueManager.h"


typedef NS_ENUM(NSInteger, BBZFilterLayerType) {
    BBZFilterLayerTypeVideo,//视频 图片 背景图 拼接
    BBZFilterLayerTypeAudio,//音频
    BBZFilterLayerTypeTransition,//转场
    BBZFilterLayerTypeEffect,//特效
    BBZFilterLayerTypeMask,//水印
    BBZFilterLayerTypeOutput,//输出
    BBZFilterLayerTypeMax,
};


@interface BBZVideoEngine ()<BBZVideoWriteControl, BBZSegmentActionDelegate>
@property (nonatomic, strong) BBZVideoModel *videoModel;
@property (nonatomic, strong) BBZEngineContext *context;
@property (nonatomic, strong) NSString *outputFile;
@property (nonatomic, strong) BBZFilterMixer *filterMixer;
@property (nonatomic, strong) BBZSchedule *schedule;
@property (nonatomic, strong) BBZCompositonDirector *director;
@property (nonatomic, strong) NSMutableDictionary *filterLayers; //@(BBZFilterLayerType):BBZFilterLayer
@property (nonatomic, strong) NSMutableSet *timePointSet;
@property (nonatomic, assign) NSUInteger intDuration;
@property (nonatomic, assign) NSMutableDictionary *timeSegments; // @(time): ActionTree



@end


@implementation BBZVideoEngine

- (instancetype)initWithModel:(BBZVideoModel *)videoModel
                context:(BBZEngineContext *)context {
    if(self = [super init]) {
        _videoModel = videoModel;
        _context = context;
        _timeSegments = [NSMutableDictionary dictionaryWithCapacity:1];
        _timePointSet = [NSMutableSet set];
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
    outputLayer.writerControl = self;
    
    BBZActionBuilderResult *builerResult = nil;
    for (int i = BBZFilterLayerTypeVideo; i < BBZFilterLayerTypeMax; i++) {
        BBZFilterLayer *layer = self.filterLayers[@(i)];
        if(i == BBZFilterLayerTypeVideo || i == BBZFilterLayerTypeTransition) {
            BBZActionBuilderResult *currentResult = [layer buildTimelineNodes:builerResult];
            layer.builderResult = currentResult;
            builerResult = currentResult;
        } else {
            BBZActionBuilderResult *currentResult = [layer buildTimelineNodes:builerResult];
            layer.builderResult = currentResult;
            [self addTimePointFrom:currentResult];
        }
    }
    [self addTimePointFrom:builerResult];
    self.intDuration = builerResult.startTime;
}

- (void)buildVideoEngine {
    self.director = [[BBZCompositonDirector alloc] init];
    self.schedule = [BBZSchedule scheduleWithMode:self.context.scheduleMode];
    self.schedule.observer = self.director;
}


- (void)prepareForStart {
    if(!self.director.timePointsArray) {
        NSMutableArray *mutableArray =  [NSMutableArray arrayWithArray:self.timePointSet.allObjects];
        [mutableArray sortUsingComparator:^NSComparisonResult(NSNumber  *obj1, NSNumber *obj2) {
            return (obj1.unsignedIntegerValue < obj2.unsignedIntegerValue) ? NSOrderedAscending : NSOrderedDescending;
        }];
        self.director.timePointsArray = mutableArray;
    }
    //进行滤镜链时间区间创建
    
    //进行滤镜链合并 , 创建实例实例filterAction;
}

#pragma mark - Public


- (BOOL)start {
    [self prepareForStart];
    [self.director start];
    [self.schedule startTimeline];
    return YES;
}

- (BOOL)pause {
    [self.director pause];
    [self.schedule pauseTimeline];
    return YES;
}

- (BOOL)cancel {
    [self.director cancel];
    [self.schedule stopTimeline];
    return YES;
}

- (CGFloat)videoModelCombinedDuration {
    CGFloat duration  = self.intDuration / BBZVideoDurationScale;
    return duration;
}

#pragma mark - WriteControl Delegate

- (void)didWriteVideoFrame {
    if(self.context.scheduleMode == BBZEngineScheduleModeExport) {
        __weak typeof(self) weakSelf = self;
        BBZRunAsynchronouslyOnTaskQueue(^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.schedule increaseTime];
        });
    }
}

- (void)didWriteAudioFrame {
    
}

#pragma mark - BBZSegmentActionDelegate

- (NSArray *)layerActionTreesBeforeTimePoint:(NSUInteger)timePoint {
    
    return nil;
}


#pragma mark - Private

#pragma mark - TimePoint

- (void)addTimePointFrom:(BBZActionBuilderResult *)result {
    for (BBZActionTree *tree in result.groupActions) {
        for (BBZAction *action in tree.allActions) {
            [self.timePointSet addObject:@(action.startTime)];
            [self.timePointSet addObject:@(action.endTime)];
        }
    }
}

#pragma mark - Schedule

- (void)updateWithTime:(CMTime)time{
    //to do check time 是否超出
}

- (void)didSeekToTime:(CMTime)time{
    
}

- (void)didReachEndTime{
    //到达结束两种情形 1.updateWithTime 2.读取资源失败并且接近尾声，
    //读取资源失败未接近尾声的时候可以通过纠错的方式来修正，比如返回一个黑帧或者返回上一帧画面(视频画面拉长或者视频将播放时长大于媒体时长，但是在action正常时常范围内)
}


@end
