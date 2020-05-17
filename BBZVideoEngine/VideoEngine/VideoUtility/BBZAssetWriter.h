//
//  BBZAssetWriter.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/15.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBZAssetWriter : NSObject
@property (nonatomic, copy) NSDictionary *videoOutputSettings;
@property (nonatomic, copy) NSDictionary *audioOutputSettings;

@property(readwrite, nonatomic) BOOL hasAudioTrack;
//@property(readwrite, nonatomic) BOOL shouldPassthroughAudio;
@property(readwrite, nonatomic) BOOL shouldInvalidateAudioSampleWhenDone;

@property(nonatomic, copy) void(^completionBlock)(BOOL sucess, NSError*);

- (instancetype)initWithOutputFile:(NSString *)strFilePath size:(CGSize)videoSize fileType:(NSString *)fileType;
- (void)startWriting;

- (void)writeVideoFrameBuffer:(CMSampleBufferRef)frameBuffer;
- (void)writeVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)time;
- (void)writeAudioFrameBuffer:(CMSampleBufferRef)frameBuffer;

- (void)cancleWriting;
- (void)finishWriting;
@end

