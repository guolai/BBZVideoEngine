//
//  BBZAssetReader.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/6.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class BBZAssetReaderOutput;

@interface BBZAssetReader : NSObject
@property (nonatomic, strong, readonly) AVAsset *asset;
@property (nonatomic, strong, readonly) AVVideoComposition *videoComposition;
@property (nonatomic, strong, readonly) AVAudioMix *audioMix;
@property (nonatomic, strong, readonly) NSArray<BBZAssetReaderOutput*> *outputs;
@property (nonatomic, assign) CMTimeRange timeRange;

- (instancetype)initWithAsset:(AVAsset *)asset;
//- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;
- (instancetype)initWithAsset:(AVAsset *)asset videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVAudioMix *)audioMix;

- (void)addOutput:(BBZAssetReaderOutput *)output;
- (void)removeOutput:(BBZAssetReaderOutput *)output;

@end


@interface BBZAssetReaderOutput : NSObject
@property (nonatomic, strong, readonly) NSDictionary *outputSettings;
@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)initWithOutputSettings:(NSDictionary *)outputSettings;
- (void)startProcessing;
- (void)endProcessing;
- (void)cancelProcessing;

@end


@interface BBZAssetReaderSequentialAccessVideoOutput : BBZAssetReaderOutput
@property (nonatomic, assign, readonly) CMSampleBufferRef currentSampleBuffer;
@property (nonatomic, readonly) BOOL isReadingToEndTime;

- (CMSampleBufferRef)nextSampleBuffer;
@end

@interface BBZAssetReaderRandomAccessVideoOutput : BBZAssetReaderOutput
@property (nonatomic, assign, readonly) CMSampleBufferRef currentSampleBuffer;
- (CMSampleBufferRef)sampleBufferAtTime:(CMTime)time;
@end


@interface BBZAssetReaderAudioOutput : BBZAssetReaderOutput
@property (nonatomic, readonly) BOOL isReadingToEndTime;

- (CMSampleBufferRef)nextSampleBuffer;
- (void)seekToTime:(CMTime)time;

@end

