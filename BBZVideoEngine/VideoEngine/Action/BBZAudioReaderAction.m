//
//  BBZAudioReaderAction.m
//  BBZVideoEngine
//
//  Created by bob on 2020/6/10.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZAudioReaderAction.h"
#import "BBZAssetReader.h"
#import "BBZVideoAsset.h"
#import "GPUImageOutput.h"

@interface BBZAudioReaderAction ()
@property (nonatomic, strong) BBZAssetReader *reader;
@property (nonatomic, strong) BBZAssetReaderAudioOutput *audioOutPut;
@property (nonatomic, strong) BBZInputAudioParam *inputAudioParam;
@property (nonatomic, assign) CMSampleBufferRef sampleBuffer;
@end


@implementation BBZAudioReaderAction

- (void)buildReader {
    if(!self.reader) {
        self.reader = [[BBZAssetReader alloc] initWithAsset:self.audioCompostion.asset videoComposition:nil audioMix:self.audioCompostion.audioMix];
        self.reader.timeRange = self.audioCompostion.playTimeRange;
        self.audioOutPut = [[BBZAssetReaderAudioOutput alloc] initWithOutputSettings:self.audioCompostion.audioSetting];
        [self.reader addOutput:self.audioOutPut];
        self.inputAudioParam = [[BBZInputAudioParam alloc] init];
    }
}

- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    
    CMSampleBufferRef sampleBuffer = self.sampleBuffer;
    if(!sampleBuffer) {
        sampleBuffer = [self.audioOutPut nextSampleBuffer];
    }
    if(!sampleBuffer) {
        self.inputAudioParam.sampleBuffer = nil;
        self.inputAudioParam.time = time;
        return ;
    }
//    runAsynchronouslyOnVideoProcessingQueue(^{
        CMTime lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        lastSamplePresentationTime = CMTimeSubtract(lastSamplePresentationTime, self.reader.timeRange.start);
//        BBZINFO(@"audio sample time1:%@, realtime:%@", [NSValue valueWithCMTime:lastSamplePresentationTime], [NSValue valueWithCMTime:time]);
        NSTimeInterval nDiff = CMTimeGetSeconds(CMTimeSubtract(lastSamplePresentationTime, time));
        NSTimeInterval minDuration = 0.34;
        if(nDiff > minDuration) {
//            BBZERROR(@"newFrameAtTime skip dif:%f sample time:%@, realtime:%@", nDiff,[NSValue valueWithCMTime:lastSamplePresentationTime], [NSValue valueWithCMTime:time]);
            self.sampleBuffer = sampleBuffer;
            self.inputAudioParam.sampleBuffer = nil;
            self.inputAudioParam.time = time;
            return;
            
        }
        CMSampleBufferRef adjustSampleBuffer = [self adjustTime:sampleBuffer by:self.reader.timeRange.start];
        self.inputAudioParam.sampleBuffer = adjustSampleBuffer;
        CFRelease(adjustSampleBuffer);
        self.inputAudioParam.time = time;
        self.sampleBuffer = nil;
        lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(self.inputAudioParam.sampleBuffer);
//        BBZINFO(@"audio sample time2:%@, realtime:%@", [NSValue valueWithCMTime:lastSamplePresentationTime], [NSValue valueWithCMTime:time]);
    
        
//    });
}

- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef) sample by:(CMTime) offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    
    return sout;
}


- (BBZInputAudioParam *)inputAudioAtTime:(CMTime)time {
    return self.inputAudioParam;
}
- (void)lock {
    [super lock];
    if(!self.reader) {
        [self buildReader];
        [self.audioOutPut startProcessing];
    }
}

- (void)setSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if(sampleBuffer &&  _sampleBuffer == sampleBuffer) {
        return;
    }
    if(sampleBuffer) {
        CFRetain(sampleBuffer);
    }
    if(_sampleBuffer) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = nil;
    }
    _sampleBuffer = sampleBuffer;
}


- (void)destroySomething{

    self.sampleBuffer = nil;
    self.inputAudioParam = nil;
    [self.audioOutPut endProcessing];
    [self.reader removeOutput:self.audioOutPut];
    self.audioOutPut = nil;
    self.reader = nil;
}


@end
