//
//  BBZVideoTools.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZAVAssetExportSession.h"
#import "BBZVideoAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBZVideoTools : NSObject
+ (AVAsset * __nullable)mergeVideoFile:(NSString *)videoFile
                          andAudioFile:(NSString *)audioFile
                            videoSpeed:(CGFloat)speed;

+ (AVAssetExportSession *)saveOutputVideoWithAsset:(AVAsset *)asset
                                        toFilePath:(NSString *)targetPath
                                          metaInfo:(NSArray<AVMetadataItem *> *_Nullable)metaInfo
                                        completion:(void (^__nullable)(BOOL success, NSError * __nullable error))handler;

+ (BBZAVAssetExportSession *)saveOutputVideoWithAsset:(AVAsset *)asset
                                            toFilePath:(NSString *)targetPath
                                         videoSettings:(NSDictionary * __nullable)videoSettings
                                         audioSettings:(NSDictionary * __nullable)audioSettings
                                              audioMix:(AVAudioMix * __nullable)audioMix
                                             modelInfo:(NSObject *_Nullable)model
                                            completion:(void (^ __nullable)(BOOL success, NSError * __nullable error))handler;

+ (CMTime)durationOfAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange;

+ (CMTime)durationOfVideoAtPath:(NSString *)path timeRange:(CMTimeRange)timeRange;

+ (CMTime)audioDurationOfAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange;

+ (CGSize)resolutionForVideoSize:(CGSize)videoSize limitedByLongestEdge:(CGFloat)longestEdge;

+ (CGSize)resolutionForVideoSize:(CGSize)videoSize limitedByResolution:(NSInteger)resolutionLimit;

+ (int)adjustVideoSizeValue:(CGFloat)fValue;

+ (void)readAVAsset:(AVAsset *)videoAsset
          forVideoSize:(CGSize *)videoSize
          videoBitRate:(NSInteger *)videoBitRate
             frameRate:(NSInteger *)frameRate
          audioBitRate:(NSInteger *)audioBitRate;
@end

NS_ASSUME_NONNULL_END
