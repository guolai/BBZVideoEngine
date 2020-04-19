//
//  BBZAVAssetExportSession.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBZAVAssetExportSession : NSObject
typedef void(^BBZAVAssetExportProgressBlock)(CGFloat progress);
typedef BOOL(^BBZAVAssetExportHandleSamplebufferBlock)(BBZAVAssetExportSession *exportSession, CMSampleBufferRef sampleBuffer, AVAssetWriterInputPixelBufferAdaptor *videoPixelBufferAdaptor);

@property (nonatomic, copy) BBZAVAssetExportProgressBlock exportProgressBlock;
@property (nonatomic, copy) BBZAVAssetExportHandleSamplebufferBlock exportHandleSampleBufferBlock;

@property (nonatomic, strong, readonly) AVAsset *asset;
@property (nonatomic, copy) AVVideoComposition *videoComposition;
@property (nonatomic, copy) AVAudioMix *audioMix;
@property (nonatomic, copy) NSString *outputFileType;
@property (nonatomic, copy) NSURL *outputURL;
@property (nonatomic, copy) NSDictionary *videoInputSettings;
@property (nonatomic, copy) NSDictionary *videoSettings;
@property (nonatomic, copy) NSDictionary *audioSettings;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;
@property (nonatomic, copy) NSArray *metadata;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, assign, readonly) AVAssetExportSessionStatus status;
//@property (nonatomic, strong, readonly) BBZVideoRenderFilter *videoRenderFilter;
@property (nonatomic, assign, readonly) CMTime lastSamplePresentationTime;
@property (nonatomic, assign, readonly) CGSize videoSize;
@property (nonatomic, assign) BOOL shouldPassThroughNatureSize;//针对视频加背景，videosize并非视频自身将要输出的


+ (id)exportSessionWithAsset:(AVAsset *)asset;
- (id)initWithAsset:(AVAsset *)asset;


- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(BBZAVAssetExportSession *))handler;
- (void)cancelExport;
@end

NS_ASSUME_NONNULL_END
