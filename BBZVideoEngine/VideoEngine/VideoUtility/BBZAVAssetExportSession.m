//
//  BBZAVAssetExportSession.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZAVAssetExportSession.h"

@interface BBZAVAssetExportSession ()

@property (nonatomic, assign, readwrite) float progress;

@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetReaderVideoCompositionOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderAudioMixOutput *audioOutput;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *videoPixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, assign) dispatch_queue_t inputQueue;
@property (nonatomic, assign, readwrite) CMTime lastSamplePresentationTime;
@property (nonatomic, strong) void (^completionHandler)(BBZAVAssetExportSession *);
//@property (nonatomic, strong, readwrite) BBZVideoRenderFilter *videoRenderFilter;


@end

@implementation BBZAVAssetExportSession {
    NSError *_error;
    NSTimeInterval _duration;
    
}

- (void)dealloc {
    NSLog(@"BBZAVAssetExportSession dealloc");
}

+ (id)exportSessionWithAsset:(AVAsset *)asset {
    return [BBZAVAssetExportSession.alloc initWithAsset:asset];
}

- (id)initWithAsset:(AVAsset *)asset {
    if ((self = [super init])) {
        _asset = asset;
        _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    }
    return self;
}

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(BBZAVAssetExportSession *))handler {
    NSParameterAssert(handler != nil);
    [self cancelExport];
    self.completionHandler = handler;
    
    if (!self.outputURL) {
        _error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@
                  {
        NSLocalizedDescriptionKey: @"Output URL not set"
        }];
        handler(self);
        return;
    }
    
    NSError *readerError;
    self.reader = [AVAssetReader.alloc initWithAsset:self.asset error:&readerError];
    if (readerError) {
        _error = readerError;
        handler(self);
        return;
    }
    
    NSError *writerError;
    self.writer = [AVAssetWriter assetWriterWithURL:self.outputURL fileType:self.outputFileType error:&writerError];
    if (writerError) {
        _error = writerError;
        handler(self);
        return;
    }
    
    self.reader.timeRange = self.timeRange;
    self.writer.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    self.writer.metadata = self.metadata;
    
    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    
    
    if (CMTIME_IS_VALID(self.timeRange.duration) &&
        !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration))  {
        _duration = CMTimeGetSeconds(self.timeRange.duration);
    }  else {
        _duration = CMTimeGetSeconds(self.asset.duration);
    }
    
    if (videoTracks.count > 0) {
        self.videoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:self.videoInputSettings];
        self.videoOutput.alwaysCopiesSampleData = NO;
        if (self.videoComposition) {
            self.videoOutput.videoComposition = self.videoComposition;
        } else {
            self.videoOutput.videoComposition = [self buildDefaultVideoComposition];
        }
        if ([self.reader canAddOutput:self.videoOutput]) {
            [self.reader addOutput:self.videoOutput];
        }
        
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
        self.videoInput.expectsMediaDataInRealTime = NO;
        if ([self.writer canAddInput:self.videoInput]) {
            [self.writer addInput:self.videoInput];
        }
        NSDictionary *pixelBufferAttributes = @{
            (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
            (id)kCVPixelBufferWidthKey: @(self.videoOutput.videoComposition.renderSize.width),
            (id)kCVPixelBufferHeightKey: @(self.videoOutput.videoComposition.renderSize.height),
            @"IOSurfaceOpenGLESTextureCompatibility": @YES,
            @"IOSurfaceOpenGLESFBOCompatibility": @YES,
        };
        self.videoPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:pixelBufferAttributes];
    }
    
    //
    //Audio output
    //
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        self.audioOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:nil];
        self.audioOutput.alwaysCopiesSampleData = NO;
        self.audioOutput.audioMix = self.audioMix;
        if ([self.reader canAddOutput:self.audioOutput])  {
            [self.reader addOutput:self.audioOutput];
        }
    } else {
        // Just in case this gets reused
        self.audioOutput = nil;
    }
    
    //
    // Audio input
    //
    if (self.audioOutput) {
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
        self.audioInput.expectsMediaDataInRealTime = NO;
        if ([self.writer canAddInput:self.audioInput]) {
            [self.writer addInput:self.audioInput];
        }
    }
    
    [self.writer startWriting];
    [self.reader startReading];
    [self.writer startSessionAtSourceTime:self.timeRange.start];
    
    __block BOOL videoCompleted = NO;
    __block BOOL audioCompleted = NO;
    __weak typeof(self) wself = self;
    NSString *str = [NSString stringWithFormat:@"VideoEncoderInputQueue-%p",self];
    self.inputQueue = dispatch_queue_create([str UTF8String], DISPATCH_QUEUE_SERIAL);
    if (videoTracks.count > 0) {
        [self.videoInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^{
            if (![wself encodeReadySamplesFromOutput:wself.videoOutput toInput:wself.videoInput]) {
                @synchronized(wself) {
                    videoCompleted = YES;
                    if (audioCompleted)  {
                        [wself finish];
                    }
                }
            }
        }];
    } else {
        videoCompleted = YES;
    }
    
    if (!self.audioOutput) {
        audioCompleted = YES;
    } else {
        [self.audioInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^{
            if (![wself encodeReadySamplesFromOutput:wself.audioOutput toInput:wself.audioInput]) {
                @synchronized(wself)  {
                    audioCompleted = YES;
                    if (videoCompleted) {
                        [wself finish];
                    }
                }
            }
        }];
    }
}

- (BOOL)encodeReadySamplesFromOutput:(AVAssetReaderOutput *)output toInput:(AVAssetWriterInput *)input {
    while (input.isReadyForMoreMediaData) {
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        if (sampleBuffer) {
            BOOL handled = NO;
            BOOL error = NO;
            
            if (self.reader.status != AVAssetReaderStatusReading ||
                self.writer.status != AVAssetWriterStatusWriting) {
                handled = YES;
                error = YES;
                NSLog(@"bobo error");
            }
            if(self.videoOutput == output) {
                static NSInteger videocount = 1;
                //                self.lastVideoTime =
                NSLog(@"current video Time======:%f , %ld",CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)), videocount);
                videocount++;
            } else {
                static NSInteger audiocount = 1;
                NSLog(@"current audio Time------:%f, %ld",CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)), audiocount);
                audiocount++;
            }
            while (self.videoInput.readyForMoreMediaData == NO && self.videoInput == input && !handled) {
                if (self.writer.status != AVAssetWriterStatusWriting)
                {
                    return NO;
                }
                
                usleep(10000);
                NSLog(@"sleep on writing video");
            }
            while (self.audioInput.readyForMoreMediaData == NO && self.audioInput == input && !handled) {
                if (self.writer.status != AVAssetWriterStatusWriting)
                {
                    return NO;
                }
                
                usleep(10000);
                NSLog(@"sleep on writing audio");
            }
            
            if (!handled && self.videoOutput == output) {
                // update the video progress
                _lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//                NSLog(@"current time %f", CMTimeGetSeconds(_lastSamplePresentationTime));
                _lastSamplePresentationTime = CMTimeSubtract(_lastSamplePresentationTime, self.timeRange.start);
                self.progress = _duration == 0 ? 1 : CMTimeGetSeconds(_lastSamplePresentationTime) / _duration;
                if (self.exportProgressBlock) {
                    self.exportProgressBlock(self.progress);
                }
                if(self.exportHandleSampleBufferBlock) {
                    handled = self.exportHandleSampleBufferBlock(self, sampleBuffer, self.videoPixelBufferAdaptor);
                }
            }
            
            @try {
                if (!handled && ![input appendSampleBuffer:sampleBuffer]) {
                    error = YES;
                    NSLog(@"error 222");
                } 
            } @catch (NSException *exception) {
                error = YES;
            } @finally {
            }
            
            CFRelease(sampleBuffer);
            
            if (error) {
                return NO;
            }
        } else {
            [input markAsFinished];
            return NO;
        }
    }
    return YES;
}



- (AVMutableVideoComposition *)buildDefaultVideoComposition {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    // Make a "pass through video track" video composition.
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
    
    NSMutableArray *arrayLayerInstruction = [NSMutableArray arrayWithCapacity:2];
    
    for (AVAssetTrack *videoTrack in [self.asset tracksWithMediaType:AVMediaTypeVideo]) {
        
        // get the frame rate from videoSettings, if not set then try to get it from the video track,
        // if not set (mainly when asset is AVComposition) then use the default frame rate of 30
        float trackFrameRate = 0;
        if (self.videoSettings) {
            NSDictionary *videoCompressionProperties = [self.videoSettings objectForKey:AVVideoCompressionPropertiesKey];
            if (videoCompressionProperties)  {
                NSNumber *maxKeyFrameInterval = [videoCompressionProperties objectForKey:AVVideoMaxKeyFrameIntervalKey];
                if (maxKeyFrameInterval)  {
                    trackFrameRate = maxKeyFrameInterval.floatValue;
                }
            }
        } else {
            trackFrameRate = [videoTrack nominalFrameRate];
        }
        
        if (trackFrameRate == 0) {
            trackFrameRate = 30;
        }
        
        videoComposition.frameDuration = CMTimeMake(1, trackFrameRate);
        CGSize targetSize = CGSizeMake([self.videoSettings[AVVideoWidthKey] floatValue], [self.videoSettings[AVVideoHeightKey] floatValue]);
        CGSize naturalSize = [videoTrack naturalSize];
        CGAffineTransform transform = videoTrack.preferredTransform;
        CGFloat videoAngleInDegree  = atan2(transform.b, transform.a) * 180 / M_PI;
        CGRect resultRect = CGRectApplyAffineTransform(CGRectMake(0, 0, naturalSize.width, naturalSize.height), videoTrack.preferredTransform);
        //    NSLog(@"videoAngleInDegree=%f, beforeRect=%@, afterRect=%@", videoAngleInDegree, NSStringFromCGRect(CGRectMake(0, 0, naturalSize.width, naturalSize.height)), NSStringFromCGRect(resultRect));
        
        if (videoAngleInDegree == 90 || videoAngleInDegree == -90) {
            CGRect interRect = CGRectIntersection(resultRect, CGRectMake(0, 0, naturalSize.height, naturalSize.width));
            if (fabs(interRect.size.width - fabs(naturalSize.width)) > 0.01 || fabs(interRect.size.height - fabs(naturalSize.height)) > 0.01) {
                // 需要矫正
                if (videoAngleInDegree == 90 && transform.a == 0.f && transform.b == 1.f && transform.c == -1.f && transform.d == 0.f) {
                    transform.tx = naturalSize.height;
                    transform.ty = 0;
                } else if (videoAngleInDegree == -90 && transform.a == 0.f && transform.b == -1.f && transform.c == 1.f && transform.d == 0.f) {
                    transform.tx = 0;
                    transform.ty = naturalSize.width;
                }
                // 其他情况暂不支持
            }
            CGFloat width = naturalSize.width;
            naturalSize.width = naturalSize.height;
            naturalSize.height = width;
        } else if (videoAngleInDegree == 180) {
            CGRect interRect = CGRectIntersection(resultRect, CGRectMake(0, 0, naturalSize.width, naturalSize.height));
            if (fabs(interRect.size.width - fabs(naturalSize.width)) > 0.01 || fabs(interRect.size.height - fabs(naturalSize.height)) > 0.01) {
                if (transform.a == -1.f && transform.b == 0.f && transform.c == 0.f && transform.d == -1.f) {
                    transform.tx = naturalSize.width / 1.f;
                    transform.ty = naturalSize.height / 1.f;
                }
            }
        }
        if(self.shouldPassThroughNatureSize) {
            if(naturalSize.width > targetSize.width *1.5) {
                targetSize = CGSizeMake(targetSize.width *1.5, targetSize.width *1.5 * naturalSize.height / naturalSize.width);
                //将渲染尺寸适当缩小
            } else {
                targetSize = naturalSize;
            }
        }
        videoComposition.renderSize = naturalSize;
        // center inside
        {
            float ratio;
            float xratio = targetSize.width / naturalSize.width;
            float yratio = targetSize.height / naturalSize.height;
            ratio = MIN(xratio, yratio);
            
            float postWidth = naturalSize.width * ratio;
            float postHeight = naturalSize.height * ratio;
            float transx = (targetSize.width - postWidth) / 2;
            float transy = (targetSize.height - postHeight) / 2;
            
            CGAffineTransform matrix = CGAffineTransformMakeTranslation(transx / xratio, transy / yratio);
            matrix = CGAffineTransformScale(matrix, ratio / xratio, ratio / yratio);
            transform = CGAffineTransformConcat(transform, matrix);
        }
        
        
        
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        [passThroughLayer setTransform:transform atTime:kCMTimeZero];
        [arrayLayerInstruction addObject:passThroughLayer];
    }
    
    
    
    passThroughInstruction.layerInstructions = arrayLayerInstruction;
    videoComposition.instructions = @[passThroughInstruction];
    //    videoComposition.customVideoCompositorClass = [CustomVideoCompositing class];
    return videoComposition;
}

- (void)finish {
    // Synchronized block to ensure we never cancel the writer before calling finishWritingWithCompletionHandler
    if (self.reader.status == AVAssetReaderStatusCancelled || self.writer.status == AVAssetWriterStatusCancelled) {
        return;
    }
    
    if (self.writer.status == AVAssetWriterStatusFailed) {
        [self complete];
    } else if (self.reader.status == AVAssetReaderStatusFailed) {
        [self.writer cancelWriting];
        [self complete];
    } else {
        [self.writer finishWritingWithCompletionHandler:^ {
            [self complete];
        }];
    }
}

- (void)complete {
    if (self.writer.status == AVAssetWriterStatusFailed || self.writer.status == AVAssetWriterStatusCancelled) {
        [NSFileManager.defaultManager removeItemAtURL:self.outputURL error:nil];
    }
    
    if (self.completionHandler) {
        self.completionHandler(self);
        self.completionHandler = nil;
    }
}

- (NSError *)error {
    if (_error) {
        return _error;
    } else {
        return self.writer.error ? : self.reader.error;
    }
}

- (AVAssetExportSessionStatus)status {
    switch (self.writer.status) {
        default:
        case AVAssetWriterStatusUnknown:
            return AVAssetExportSessionStatusUnknown;
        case AVAssetWriterStatusWriting:
            return AVAssetExportSessionStatusExporting;
        case AVAssetWriterStatusFailed:
            return AVAssetExportSessionStatusFailed;
        case AVAssetWriterStatusCompleted:
            return AVAssetExportSessionStatusCompleted;
        case AVAssetWriterStatusCancelled:
            return AVAssetExportSessionStatusCancelled;
    }
}

- (void)cancelExport {
    if (self.inputQueue) {
        dispatch_async(self.inputQueue, ^
                       {
            [self.writer cancelWriting];
            [self.reader cancelReading];
            [self complete];
            [self reset];
        });
    }
}

//- (BBZVideoRenderFilter *)videoRenderFilter {
//    if(!_videoRenderFilter) {
//        _videoRenderFilter = [[BBZVideoRenderFilter alloc] init];
//        _videoRenderFilter.videoSize = self.videoSize;
//    }
//    return _videoRenderFilter;
//}

- (CGSize)videoSize {
    CGFloat width = [[self.videoSettings objectForKey:AVVideoWidthKey] floatValue];
    CGFloat heith = [[self.videoSettings objectForKey:AVVideoHeightKey] floatValue];
    return CGSizeMake(width, heith);
}

- (void)reset {
    _error = nil;
    self.progress = 0;
    self.reader = nil;
    self.videoOutput = nil;
    self.audioOutput = nil;
    self.writer = nil;
    self.videoInput = nil;
    self.videoPixelBufferAdaptor = nil;
    self.audioInput = nil;
    self.inputQueue = nil;
    self.completionHandler = nil;
}

@end

