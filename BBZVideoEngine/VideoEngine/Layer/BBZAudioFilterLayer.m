//
//  BBZAudioFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZAudioFilterLayer.h"
#import "BBZAudioReaderAction.h"
#import "BBZVideoSourceAction.h"

@implementation BBZAudioFilterLayer
- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    BBZActionBuilderResult *builder = nil;
    builder = [self buildAudioTimeLine:inputBuilder];
    return builder;
}

- (BBZActionBuilderResult *)buildAudioTimeLine:(BBZActionBuilderResult *)inputBuilderResult {
    
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = inputBuilderResult.startTime;
    builder.groupIndex = 0;
    NSMutableArray *mtblArray = [NSMutableArray array];
    for (BBZActionTree *spliceTree in inputBuilderResult.groupActions) {
        NSArray *array = spliceTree.allActions;
        [mtblArray addObjectsFromArray:array];
    }
    [self buildAudioAction:mtblArray duration:builder.startTime];
    
    builder.groupActions = [NSArray array];
    return builder;
    
}

- (void)buildAudioAction:(NSArray *)actions duration:(NSInteger)duration{
    BBZAudioCompostion *audioComposition = [[BBZAudioCompostion alloc] init];
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSMutableArray *audioInputParameters = [NSMutableArray array];
    BOOL bHaveAudio = NO;
//    NSUInteger totalDuration = 0;
//    CMTime playStart = kCMTimeZero;
    for (BBZAction *action in actions) {
        if([action isKindOfClass:[BBZVideoSourceAction class]]) {
            
            BBZVideoSourceAction *videoAction = (BBZVideoSourceAction *)action;
            BBZVideoAsset *videoAsset = ((BBZVideoAsset *)videoAction.asset);
            AVAsset *sourceAsset = videoAsset.asset;
            NSUInteger tmpDuration  = MIN(videoAction.endTime - videoAction.startTime, videoAsset.playDuration);
            if(tmpDuration < 10) {
                continue;
            }
//            totalDuration+= tmpDuration;
            CMTimeRange timeRange = CMTimeRangeMake(videoAsset.playTimeRange.start, CMTimeMake(tmpDuration, BBZVideoDurationScale));
            CMTime startTime = CMTimeMake(videoAction.startTime, BBZVideoDurationScale);
//            if(!bHaveAudio) {
//                playStart = startTime;
//            }
            bHaveAudio = YES;
            
            BBZINFO(@"audio track count :%d", [sourceAsset tracksWithMediaType:AVMediaTypeAudio].count);
            AVAssetTrack *audioTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
             AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:timeRange ofTrack:audioTrack atTime:startTime error:nil];
            BBZINFO(@"AudioTrack insertTimeRange,startTime:%@,%@", [NSValue valueWithCMTimeRange:timeRange], [NSValue valueWithCMTime:startTime]);
            AVMutableAudioMixInputParameters *trackParam = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
            [trackParam setVolume:1.0 atTime:kCMTimeZero];
            trackParam.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
            [audioInputParameters addObject:trackParam];
        }
    }
    audioMix.inputParameters = audioInputParameters;
    BBZAudioReaderAction *readerAction = [[BBZAudioReaderAction alloc] init];
    readerAction.startTime = 0;
    readerAction.duration = duration;
    readerAction.audioCompostion = audioComposition;
    audioComposition.asset = composition;
    audioComposition.audioMix = audioMix;
    audioComposition.audioSetting = self.context.videoSettings.audioOutputSettings;
    audioComposition.playTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(duration, BBZVideoDurationScale));
    if(bHaveAudio) {
        self.audioAction = readerAction;
    }
}

@end
