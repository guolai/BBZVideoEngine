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
        self.reader = [[BBZAssetReader alloc] initWithAsset:(AVAsset *)videoAsset.asset videoComposition:videoAsset.videoCompostion audioMix:nil];
        self.reader.timeRange = videoAsset.playTimeRange;
        self.videoOutPut = [[BBZAssetReaderSequentialAccessVideoOutput alloc] initWithOutputSettings:nil];
        [self.reader addOutput:self.videoOutPut];
        self.lastTime = kCMTimeZero;
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
    BOOL bShouldDecodeNextBuffer = NO;
    CMTime relativeTime = CMTimeSubtract(time, CMTimeMake(self.startTime * BBZActionTimeToScheduleTime, BBZScheduleTimeScale));
    do {
        BOOL bDidReachEnd = NO;
        if(bShouldDecodeNextBuffer) {
            sampleBuffer = [self.videoOutPut nextSampleBuffer];
            if(sampleBuffer) {
                self.sampleBuffer = sampleBuffer;
            } else {
                bDidReachEnd = YES;
                bShouldDecodeNextBuffer = NO;
            }
        }
        if(!bDidReachEnd) {
            CMTime lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(self.sampleBuffer);
            lastSamplePresentationTime = CMTimeSubtract(lastSamplePresentationTime, self.reader.timeRange.start);
            NSTimeInterval nDiff = CMTimeGetSeconds(CMTimeSubtract(lastSamplePresentationTime, relativeTime));
            NSTimeInterval minDuration = CMTimeGetSeconds(CMTimeSubtract(time, self.lastTime));
            minDuration = fabs(minDuration / 2.0);
            if(minDuration < 1.0/120.0) {
                minDuration = 1.0/120.0;
            } else if(minDuration > 1.0 / 60.0) {
                minDuration = 1.0 / 60.0;
            }
            BBZINFO(@"readeraction newFrameAtTime  dif:%.4f,rltime:%.4f,stime:%.4f,rtime:%.4f,minduration:%.4ff", nDiff, CMTimeGetSeconds(relativeTime), CMTimeGetSeconds(lastSamplePresentationTime), CMTimeGetSeconds(time), minDuration);
            if(nDiff > 0.0 && nDiff > minDuration) {
                //下一帧还需要复用
                if(self.sampleBuffer) {
                    self.usedSampleBuffer = self.sampleBuffer;
                }
                bShouldDecodeNextBuffer = NO;
            } else if(fabs(nDiff) <= minDuration) {
                self.usedSampleBuffer = self.sampleBuffer;
                self.sampleBuffer = nil;
                bShouldDecodeNextBuffer = NO;
            } else {
                bShouldDecodeNextBuffer = YES;
                BBZINFO(@"readeraction should fine next");
            }
        }
        
    } while (bShouldDecodeNextBuffer);
    
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
    self.usedSampleBuffer = nil;
    [self.videoOutPut endProcessing];
    [self.reader removeOutput:self.videoOutPut];
    self.inputSourceParam = nil;
    self.videoOutPut = nil;
    self.reader = nil;
}

@end
