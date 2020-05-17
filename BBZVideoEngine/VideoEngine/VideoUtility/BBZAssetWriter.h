//
//  BBZAssetWriter.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/15.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZVideoControl.h"


@interface BBZAssetWriter : NSObject
@property (nonatomic, copy) NSDictionary *videoOutputSettings;
@property (nonatomic, copy) NSDictionary *audioOutputSettings;

@property (readwrite, nonatomic) BOOL hasAudioTrack;
//@property (readwrite, nonatomic) BOOL shouldPassthroughAudio;
@property (readwrite, nonatomic) BOOL shouldInvalidateAudioSampleWhenDone;

@property (nonatomic, copy) void(^completionBlock)(BOOL sucess, NSError *error);
@property (nonatomic, weak) id<BBZVideoWriteControl> writeControl;

- (instancetype)initWithOutputFile:(NSString *)strFilePath size:(CGSize)videoSize fileType:(NSString *)fileType;
- (void)startWriting;

- (void)writeVideoFrameBuffer:(CMSampleBufferRef)frameBuffer;
- (void)writeVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)time;
- (void)writeSyncVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)time;//to do 这里是否需要让音视频各自为不同的队列
- (void)writeAudioFrameBuffer:(CMSampleBufferRef)frameBuffer;

- (void)cancleWriting;
- (void)finishWriting;
@end

