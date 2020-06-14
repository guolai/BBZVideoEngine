//
//  BBZVideoReaderAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoReaderAction.h"
#import "BBZAssetReader.h"
#import "BBZVideoAsset.h"
#import "GPUImageColorConversion.h"
#import "GPUImageFramebuffer+BBZ.h"
extern const int BBZActionTimeToScheduleTime;
@interface BBZVideoReaderAction ()
@property (nonatomic, strong) BBZAssetReader *reader;
@property (nonatomic, strong) BBZAssetReaderSequentialAccessVideoOutput *videoOutPut;
@property (nonatomic, strong) BBZInputSourceParam *inputSourceParam;
@property (nonatomic, assign) CMSampleBufferRef sampleBuffer;
@property (nonatomic, assign) CMSampleBufferRef usedSampleBuffer;
@property (nonatomic, assign) CMTime lastTime;
@end


@implementation BBZVideoReaderAction


- (void)buildReader {
    if(!self.reader) {
        BBZVideoAsset *videoAsset = (BBZVideoAsset *)self.asset;
        self.reader = [[BBZAssetReader alloc] initWithAsset:(AVAsset *)videoAsset.asset];
        self.reader.timeRange = videoAsset.playTimeRange;
        self.videoOutPut = [[BBZAssetReaderSequentialAccessVideoOutput alloc] initWithOutputSettings:nil];
        [self.reader addOutput:self.videoOutPut];
    }
}

- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    CMSampleBufferRef sampleBuffer = self.sampleBuffer;
    if(!sampleBuffer) {
        sampleBuffer = [self.videoOutPut nextSampleBuffer];
        if(sampleBuffer) {
            self.sampleBuffer = sampleBuffer;
        }
        if(!self.sampleBuffer) {
            BBZERROR(@"newFrameAtTime use lastfb");
            self.sampleBuffer = self.videoOutPut.currentSampleBuffer;
        }
        if(!self.sampleBuffer) {
            BBZERROR(@"newFrameAtTime use usedfb");
            self.sampleBuffer = self.usedSampleBuffer;
        }
    }
    CMTime relativeTime = CMTimeSubtract(time, CMTimeMake(self.startTime * BBZActionTimeToScheduleTime, BBZScheduleTimeScale));
    CMTime lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(self.sampleBuffer);
    lastSamplePresentationTime = CMTimeSubtract(lastSamplePresentationTime, self.reader.timeRange.start);
    NSTimeInterval nDiff = CMTimeGetSeconds(CMTimeSubtract(lastSamplePresentationTime, relativeTime));
    NSTimeInterval minDuration = CMTimeGetSeconds(CMTimeSubtract(time, self.lastTime));
    minDuration = fabs(minDuration / 2.0);
//    BBZINFO(@"newFrameAtTime  dif,rltime,stime,rtime: %.4f,%.4f,%.4f,%.4f", nDiff, CMTimeGetSeconds(relativeTime), CMTimeGetSeconds(lastSamplePresentationTime), CMTimeGetSeconds(time));
    if(nDiff > 0.001 && nDiff > minDuration) {
        //下一帧还需要复用
        self.usedSampleBuffer = self.sampleBuffer;
    } else {
        
        self.usedSampleBuffer = self.sampleBuffer;
        self.sampleBuffer = nil;
       
    }
    NSAssert(self.usedSampleBuffer, @"error nil samplebuffer");
//    lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(self.usedSampleBuffer);
//    BBZINFO(@"sample time:%@, realtime:%@", [NSValue valueWithCMTime:lastSamplePresentationTime], [NSValue valueWithCMTime:time]);
//        }
    self.lastTime = time;
}


- (void)buildInputParam {
    if(!self.inputSourceParam) {
        self.inputSourceParam = [[BBZInputSourceParam alloc] init];
        self.inputSourceParam.bVideoSource = YES;
    }
    CMSampleBufferRef sampleBuffer = self.usedSampleBuffer;
    GLfloat *preferredConversion;
    CVPixelBufferRef movieFrame = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL) {
        if(CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            preferredConversion = kColorConversion601FullRange;
        } else {
            preferredConversion = kColorConversion709;
        }
    } else {
        
        preferredConversion = kColorConversion601FullRange;
    }
    NSArray *array = [GPUImageFramebuffer BBZ_YUVFrameBufferWithCVPixelBuffer:movieFrame];
    NSAssert(array.count == 2, @"error");
    self.inputSourceParam.arrayFrameBuffer = array;
    self.inputSourceParam.mat33ParamValue = *((GPUMatrix3x3 *)preferredConversion);
}



- (BBZInputSourceParam *)inputSourceAtTime:(CMTime)time {
    [self buildInputParam];
    return self.inputSourceParam;
}

- (void)lock {
    [super lock];
    if(!self.reader) {
        [self buildReader];
        [self.videoOutPut startProcessing];
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

- (void)setUsedSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if(sampleBuffer &&  _usedSampleBuffer == sampleBuffer) {
        return;
    }
    if(sampleBuffer) {
        CFRetain(sampleBuffer);
    }
    if(_usedSampleBuffer) {
        CFRelease(_usedSampleBuffer);
        _usedSampleBuffer = nil;
    }
    _usedSampleBuffer = sampleBuffer;
}

- (void)destroySomething{
    self.sampleBuffer = nil;
    [self.videoOutPut endProcessing];
    [self.reader removeOutput:self.videoOutPut];
    self.videoOutPut = nil;
    self.reader = nil;
}

@end
