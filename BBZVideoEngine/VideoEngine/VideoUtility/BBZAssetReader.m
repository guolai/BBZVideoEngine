//
//  BBZAssetReader.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/6.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZAssetReader.h"


@interface BBZAssetReaderOutput ()
@property (nonatomic, weak) BBZAssetReader *reader;
@property (nonatomic, strong) AVAssetReader *provider;
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong, readwrite) NSDictionary *outputSettings;
@end


@interface BBZAssetReader ()
@property (nonatomic, strong, readwrite) AVAsset *asset;
@property (nonatomic, strong, readwrite) AVVideoComposition *videoComposition;
@property (nonatomic, strong, readwrite) AVAudioMix *audioMix;
@property (nonatomic, strong) NSMutableArray *allOutputs;
@end

@implementation BBZAssetReader

- (id)initWithAsset:(AVAsset *)asset {
    return [self initWithAsset:asset videoComposition:nil audioMix:nil];
}

- (id)initWithPlayerItem:(AVPlayerItem *)playerItem {
    NSAssert(false, @"not handled");
    return nil;
}

- (id)initWithAsset:(AVAsset *)asset videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVAudioMix *)audioMix {
    if (self = [super init]) {
        self.asset = asset;
        self.audioMix = audioMix;
        self.videoComposition = videoComposition;
        self.allOutputs = [NSMutableArray array];
        self.timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    }
    return self;
}

- (NSArray<BBZAssetReaderOutput*> *)outputs {
    return [NSArray arrayWithArray:self.allOutputs];
}

- (void)addOutput:(BBZAssetReaderOutput *)output {
    if (output && ![self.allOutputs containsObject:output]) {
        [self.allOutputs addObject:output];
        output.reader = self;
    }
}

- (void)removeOutput:(BBZAssetReaderOutput *)output {
    if (output) {
        [self.allOutputs removeObject:output];
        if (output.reader == self) {
            output.reader = nil;
        }
    }
}

@end



@implementation BBZAssetReaderOutput

- (id)initWithOutputSettings:(NSDictionary *)outputSettings {
    if (self = [super init]) {
        self.outputSettings = outputSettings;
    }
    return self;
}

- (void)dealloc {
    [self cleanup];
}

- (void)startProcessing {
    
}

- (void)endProcessing {
    [self cleanup];
}

- (void)cancelProcessing {
    [self cleanup];
}

- (void)cleanup {
    if ((self.provider != nil) && (self.provider.status == AVAssetReaderStatusReading)) {
        [self.provider cancelReading];
    }
    self.provider = nil;
}

- (BOOL)canRead {
    return (self.provider != nil) && (self.provider.status == AVAssetReaderStatusReading);
}

- (BOOL)isReadingToEndTime {
    return (self.provider != nil) && (self.provider.status == AVAssetReaderStatusCompleted);
}

- (NSError *)error {
    return ((self.provider != nil) && (self.provider.status == AVAssetReaderStatusFailed)) ? self.provider.error : self.lastError;
}

- (NSError *)restartProviderWithOutputs:(NSArray *)outputs timeRange:(CMTimeRange)timeRange {
    NSError *error = nil;
    self.provider = [AVAssetReader assetReaderWithAsset:self.reader.asset error:&error];
    self.provider.timeRange = timeRange;
    if (!error) {
        for (AVAssetReaderOutput *output in outputs) {
            [self.provider addOutput:output];
        }
    }
    if (![self.provider startReading]) {
        return self.provider.error;
    }
    return error;
}

- (CMSampleBufferRef)nextSampleBufferForProviderOutput:(AVAssetReaderOutput *)output {
    if (self.provider.status == AVAssetReaderStatusReading) {
        return (output != nil) ? [output copyNextSampleBuffer] : NULL;
    }
    return NULL;
}

- (CMTimeRange)timeRangeForSeekingProviderToTime:(CMTime)time {
    CMTimeRange wholeTimeRange = CMTimeRangeMake(kCMTimeZero, self.reader.asset.duration);
    CMTimeRange assetTimeRange = CMTimeRangeGetIntersection(self.reader.timeRange, wholeTimeRange);
    if (CMTimeCompare(time, assetTimeRange.start) < 0) {
        time = assetTimeRange.start;
    }
    CMTimeRange timeRange = CMTimeRangeFromTimeToTime(time, CMTimeRangeGetEnd(assetTimeRange));
    if (CMTimeCompare(timeRange.duration, kCMTimeZero) <= 0) {
        return kCMTimeRangeInvalid;
    }
    return timeRange;
}

- (AVAssetReaderOutput *)providerOutputWithMediaType:(AVMediaType)mediaType outputSettings:(NSDictionary *)outputSettings {
    AVAssetReaderOutput *output;
    if ([mediaType isEqualToString:AVMediaTypeVideo]) {
        output = [self videoCompositionOutputWithOutputSettings:outputSettings];
    } else if ([mediaType isEqualToString:AVMediaTypeAudio]) {
        output = self.reader.audioMix ? [self audioMixOutputWithOutputSettings:outputSettings] : [self audioTrackOutputWithOutputSettings:outputSettings];
    }
    if (!output) {
        self.lastError = [NSError errorWithDomain:@"asset reader can't add video output" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"asset reader can't add video output"}];
    }
    return output;
}

- (AVAssetReaderOutput *)videoCompositionOutputWithOutputSettings:(NSDictionary *)outputSettings {
    AVAssetReaderVideoCompositionOutput *output;
    NSArray *tracks = [self.reader.asset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
        output = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:tracks videoSettings:outputSettings];
         output.videoComposition = self.reader.videoComposition ? : [AVVideoComposition videoCompositionWithPropertiesOfAsset:self.reader.asset];
    }
    return output;
}

- (AVAssetReaderOutput *)audioTrackOutputWithOutputSettings:(NSDictionary *)outputSettings {
    AVAssetReaderTrackOutput *output;
    AVAssetTrack *track = [self.reader.asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (track) {
        output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:outputSettings];
    }
    return output;
}


- (AVAssetReaderOutput *)audioMixOutputWithOutputSettings:(NSDictionary *)outputSettings {
    AVAssetReaderAudioMixOutput *output;
    NSArray *tracks = [self.reader.asset tracksWithMediaType:AVMediaTypeAudio];
    if (tracks.count > 0) {
        output = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:tracks audioSettings:outputSettings];
        output.audioMix = self.reader.audioMix;
    }
    return output;
}

- (NSDictionary *)defaultVideoOutputSettings {
    return @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
}

- (NSDictionary *)defaultAudioOutputSettings {
    AudioChannelLayout acl;
    memset(&acl, 0, sizeof(AudioChannelLayout));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSData *channelLayoutAsData = [NSData dataWithBytes:&acl length:sizeof(acl)];
    
    return @{AVFormatIDKey: @(kAudioFormatLinearPCM),
             AVSampleRateKey: @(44100),
             AVNumberOfChannelsKey: @(1),
             AVLinearPCMBitDepthKey: @(16),
             AVChannelLayoutKey: channelLayoutAsData,
             AVLinearPCMIsNonInterleaved: @(YES),
             AVLinearPCMIsFloatKey: @(NO)};
}

- (void)releaseSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (sampleBuffer) {
        CFRelease(sampleBuffer);
    }
}

@end



@interface BBZAssetReaderSequentialAccessVideoOutput ()
@property (nonatomic, strong) AVAssetReaderOutput *providerOutput;
@end

@implementation BBZAssetReaderSequentialAccessVideoOutput

- (void)cleanup {
    [super cleanup];
    self.providerOutput = nil;
}

- (BOOL)restartProvider {
    AVAssetReaderOutput *output = [self providerOutputWithMediaType:AVMediaTypeVideo outputSettings:self.outputSettings];
    if (output) {
        self.providerOutput = output;
        self.lastError = [self restartProviderWithOutputs:@[self.providerOutput] timeRange:self.reader.timeRange];
    } else {
        self.lastError = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
    }
    return (self.lastError == nil);
}

- (CMSampleBufferRef)nextSampleBuffer {
    if (!self.providerOutput) {
        if (![self restartProvider]) {
            return NULL;
        }
    }
    return [self nextSampleBufferForProviderOutput:self.providerOutput];
}

@end



@interface BBZAssetReaderRandomAccessVideoOutput ()
@property (nonatomic, assign) CMTimeRange readerTimeRange;
@property (nonatomic, assign) CMSampleBufferRef nextSampleBuffer;
@property (nonatomic, assign) CMSampleBufferRef currentSampleBuffer;
@property (nonatomic, strong) AVAssetReaderOutput *providerOutput;
@end

@implementation BBZAssetReaderRandomAccessVideoOutput

- (void)cleanup {
    [super cleanup];
    self.readerTimeRange = kCMTimeRangeInvalid;
    [self releaseSampleBuffer:self.currentSampleBuffer];
    [self releaseSampleBuffer:self.nextSampleBuffer];
    self.currentSampleBuffer = NULL;
    self.nextSampleBuffer = NULL;
}

- (CMTime)headerSampleBufferTime {
    if (self.nextSampleBuffer) {
        return CMSampleBufferGetOutputPresentationTimeStamp(self.nextSampleBuffer);
    } else if (self.currentSampleBuffer) {
        return CMSampleBufferGetOutputPresentationTimeStamp(self.currentSampleBuffer);
    } else if ([self canRead] && CMTIMERANGE_IS_VALID(self.readerTimeRange)) {
        return self.readerTimeRange.start;
    }
    return kCMTimeInvalid;
}

- (BOOL)seekToTime:(CMTime)time {
    CMTimeRange timeRange = [self timeRangeForSeekingProviderToTime:time];
    if (!CMTIMERANGE_IS_VALID(timeRange)) {
        return NO;
    }
    
    AVAssetReaderOutput *output = [self providerOutputWithMediaType:AVMediaTypeVideo outputSettings:self.outputSettings];
    if (!output) {
        self.lastError = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
        return NO;
    }
    
    [self cleanup];
    self.providerOutput = output;
    self.lastError = [self restartProviderWithOutputs:@[self.providerOutput] timeRange:timeRange];
    return (self.lastError == nil);
}

- (CMSampleBufferRef)findSampleBufferAtTime:(CMTime)targetTime {
    if (![self prepareSampleBuffersAtTime:targetTime]) {
        return NULL;
    }
    if (!self.currentSampleBuffer) {
        return NULL;
    }
    if (!self.nextSampleBuffer) {
        return self.currentSampleBuffer;
    }
    
    CMTime nextSampleBufferTime = CMSampleBufferGetOutputPresentationTimeStamp(self.nextSampleBuffer);
    CMTime currentSampleBufferTime = CMSampleBufferGetOutputPresentationTimeStamp(self.currentSampleBuffer);
    NSTimeInterval nDiff = CMTimeGetSeconds(CMTimeSubtract(nextSampleBufferTime, targetTime));
    NSTimeInterval cDiff = CMTimeGetSeconds(CMTimeSubtract(targetTime, currentSampleBufferTime));
    
    if ((cDiff < 0) && (nDiff > 0)) {
        return self.currentSampleBuffer;
    } else if ((cDiff > 0) && (nDiff < 0)) {
        return self.nextSampleBuffer;
    }
    
    if ((fabs(cDiff) > fabs(nDiff)) && (fabs(nDiff) < (1.0 / 60.0))) {
        [self releaseSampleBuffer:self.currentSampleBuffer];
        self.currentSampleBuffer = self.nextSampleBuffer;
        self.nextSampleBuffer = NULL;
    }
    
    return self.currentSampleBuffer;
}

- (BOOL)prepareSampleBuffersAtTime:(CMTime)targetTime {
    CMSampleBufferRef tmpSampleBuffer = NULL;
    CMSampleBufferRef firstSampleBuffer = NULL;
    CMSampleBufferRef secondSampleBuffer = NULL;
    CMTime firstSampleBufferTime = kCMTimeNegativeInfinity;
    
    if (self.nextSampleBuffer) {
        firstSampleBuffer = self.nextSampleBuffer;
        secondSampleBuffer = self.currentSampleBuffer;
        firstSampleBufferTime = CMSampleBufferGetOutputPresentationTimeStamp(firstSampleBuffer);
    } else if (self.currentSampleBuffer) {
        firstSampleBuffer = self.currentSampleBuffer;
        firstSampleBufferTime = CMSampleBufferGetOutputPresentationTimeStamp(firstSampleBuffer);
    }
    
    while (CMTimeCompare(firstSampleBufferTime, CMTimeAdd(targetTime, CMTimeMake(1, 6000))) <= 0) {
        tmpSampleBuffer = self.canRead ? [self nextSampleBufferForProviderOutput:self.providerOutput] : NULL;
        if (tmpSampleBuffer == NULL) {
            break;
        }
  
        [self releaseSampleBuffer:secondSampleBuffer];
        secondSampleBuffer = firstSampleBuffer;
        firstSampleBuffer = tmpSampleBuffer;
        firstSampleBufferTime = CMSampleBufferGetOutputPresentationTimeStamp(firstSampleBuffer);
    }
    
    if (CMTimeCompare(firstSampleBufferTime, targetTime) > 0) {
        if (secondSampleBuffer) {
            self.nextSampleBuffer = firstSampleBuffer;
            self.currentSampleBuffer = secondSampleBuffer;
        } else {
            self.nextSampleBuffer = NULL;
            self.currentSampleBuffer = firstSampleBuffer;
        }
    } else {
        [self releaseSampleBuffer:secondSampleBuffer];
        self.nextSampleBuffer = NULL;
        self.currentSampleBuffer = firstSampleBuffer;
    }

    CMTime time = CMSampleBufferGetOutputPresentationTimeStamp(self.currentSampleBuffer);
    BBZINFO(@"[Prepare] current {v=%lli s=%i}", time.value, time.timescale);
    time = CMSampleBufferGetOutputPresentationTimeStamp(self.nextSampleBuffer);
    BBZINFO(@"[Prepare] next {v=%lli s=%i}", time.value, time.timescale);
    
    return YES;
}

- (CMSampleBufferRef)sampleBufferAtTime:(CMTime)targetTime {
    CMTime headerTime = [self headerSampleBufferTime];
    if ((CMTIME_IS_NUMERIC(headerTime) == NO) ||
        (CMTimeCompare(targetTime, headerTime) < 0) ||
        (CMTimeCompare(targetTime, CMTimeAdd(headerTime, CMTimeMake(1500, 6000))) > 0)) {
        if (![self seekToTime:targetTime]) {
            return NULL;
        }
    }
    CMSampleBufferRef sampleBuffer = [self findSampleBufferAtTime:targetTime];
    if (sampleBuffer) {
        CFRetain(sampleBuffer);
    }
    return sampleBuffer;
}

@end


#pragma mark - Class BBZAssetReaderAudioOutput

@interface BBZAssetReaderAudioOutput ()
@property (nonatomic, assign) CMTime seekingTime;
@property (nonatomic, strong) AVAssetReaderOutput *providerOutput;
@end

@implementation BBZAssetReaderAudioOutput

- (id)initWithOutputSettings:(NSDictionary *)outputSettings {
    if (self = [super initWithOutputSettings:outputSettings]) {
        self.seekingTime = kCMTimeInvalid;
    }
    return self;
}

- (void)cleanup {
    [super cleanup];
    self.providerOutput = nil;
}

- (void)restartProvider {
    CMTime time = self.reader.timeRange.start;
    if (CMTIME_IS_VALID(self.seekingTime)) {
        time = self.seekingTime;
        self.seekingTime = kCMTimeInvalid;
    }
    CMTimeRange timeRange = [self timeRangeForSeekingProviderToTime:time];
    if (!CMTIMERANGE_IS_VALID(timeRange)) {
        return;
    }
    
    AVAssetReaderOutput *output = [self providerOutputWithMediaType:AVMediaTypeAudio outputSettings:self.outputSettings];
    if (!output) {
        self.lastError = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
        return;
    }
    
    [self cleanup];
    self.providerOutput = output;
    self.lastError = [self restartProviderWithOutputs:@[self.providerOutput] timeRange:timeRange];
}

- (CMSampleBufferRef)nextSampleBuffer {
    if (!self.providerOutput) {
        [self restartProvider];
    }
    return [self nextSampleBufferForProviderOutput:self.providerOutput];
}

- (void)seekToTime:(CMTime)time {
    self.seekingTime = time;
    [self cleanup];
}

@end
