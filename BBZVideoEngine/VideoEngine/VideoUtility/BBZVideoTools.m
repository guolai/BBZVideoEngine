//
//  BBZVideoTools.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoTools.h"

@implementation BBZVideoTools
+ (AVAsset *)mergeVideoFile:(NSString *)videoFile
               andAudioFile:(NSString *)audioFile
                 videoSpeed:(CGFloat)speed {
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES,};
    
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoFile] options:options];
    NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
        NSError *error = nil;
        AVAssetTrack *track = [tracks firstObject];
        BBZINFO(@"\n\n\n******************insert VIDEO track at [%lld, %d] [%lld, %d]******************\n\n\n\n",track.timeRange.start.value, track.timeRange.start.timescale, track.timeRange.duration.value, track.timeRange.duration.timescale);
        [videoTrack insertTimeRange:track.timeRange ofTrack:track atTime:kCMTimeInvalid error:&error];
        
        if (speed != 1.0) {
            CMTime newDuration = CMTimeMake(track.timeRange.duration.value / speed, track.timeRange.duration.timescale);
            [videoTrack scaleTimeRange:track.timeRange toDuration:newDuration];
        }
        
        if (error) {
            BBZINFO(@"合成视频失败：Insert VIDEO track failed %@ %@", [error description], videoFile);
            return nil;
        }
    } else {
        BBZINFO(@"合成视频失败：视频有问题 %@", videoFile);
        NSAssert(NO, @"视频轨道为空");

        return nil;
    }
    
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:audioFile] options:options];
    AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *audioTracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count > 0) {
        NSError *error = nil;
        AVAssetTrack *track = [audioTracks firstObject];
        CMTime startTime = kCMTimeZero;
        CMTimeRange audioRange = CMTimeRangeMake(startTime, videoTrack.timeRange.duration);
        [AudioTrack insertTimeRange:audioRange ofTrack:track atTime:kCMTimeZero error:&error];
        if (error) {
            BBZINFO(@"合成视频失败：Insert AUDIO track failed %@ %@", [error description], audioFile);
            return nil;
        }
    } else {
        BBZINFO(@"合成视频失败：音轨为空 %@", audioFile);
        NSAssert(NO, @"音频为空，检查素材");
        return nil;
    }
    
    BBZINFO(@"合成视频结束");
    return mixComposition;
}

+ (AVAssetExportSession *)saveOutputVideoWithAsset:(AVAsset * __nonnull)asset
                                        toFilePath:(NSString * __nonnull)targetPath
                                          metaInfo:(NSArray<AVMetadataItem *> *_Nullable)metaInfo
                                        completion:(void (^__nullable)(BOOL success, NSError * __nullable error))handler; {
    
    NSString *fileName = [[NSString stringWithFormat:@"export-%.6f-%li", [NSDate timeIntervalSinceReferenceDate], (NSInteger)arc4random()] stringByAppendingPathExtension:@"mp4"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    BBZINFO(@"========视频保存Asset开始========");
    //    QZEVGifEffectExporterHandler *exporterHandler = [[QZEVGifEffectExporterHandler alloc] init];
    //    WSSDAVAssetExportSession *exporter = [WSSDAVAssetExportSession exportSessionWithAsset:asset];
    //    exporter.delegate = exporterHandler;
    //    exporter.shouldOptimizeForNetworkUse = YES;
    //    exporter.outputURL = url;
    //    exporter.outputFileType = AVFileTypeMPEG4;
    //    exporter.metadata = [self metaDataForAsset:asset];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.outputURL = url;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.metadata = metaInfo;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        BOOL ret = YES;
        if (exporter.error) {
            BBZINFO(@"视频保存Asset失败：%@, %@", exporter.error, targetPath);
            ret = NO;
        }
        if (ret) {
            [[NSFileManager defaultManager] moveFile:filePath toPath:targetPath replaceIfExist:YES];
        }
        BBZINFO(@"视频保存Asset结束");
        //NSLog(@"%@",exporterHandler);
        if (handler) {
            handler(ret, exporter.error);
        }
    }];
    
    return exporter;
}

+ (BBZAVAssetExportSession *)saveOutputVideoWithAsset:(AVAsset *)asset
                                            toFilePath:(NSString *)targetPath
                                         videoSettings:(NSDictionary *)videoSettings
                                         audioSettings:(NSDictionary *)audioSettings
                                              audioMix:(AVAudioMix *)audioMix
                                             modelInfo:(NSObject *_Nullable)model
                                            completion:(void (^)(BOOL success, NSError *error))handler {
    NSString *fileName = [[NSString stringWithFormat:@"export-%.6f-%li", [NSDate timeIntervalSinceReferenceDate], (NSInteger)arc4random()] stringByAppendingPathExtension:@"mp4"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    BBZINFO(@"========视频保存Asset开始========");
    BBZAVAssetExportSession *exporter = [BBZAVAssetExportSession exportSessionWithAsset:asset];
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.outputURL = url;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.videoSettings = videoSettings;
//    exporter.metadata = nil; //to do it bob
    exporter.audioSettings = audioSettings;
    exporter.audioMix = audioMix;
    [exporter exportAsynchronouslyWithCompletionHandler:^(BBZAVAssetExportSession *exportSession){
        BOOL ret = YES;
        if (exporter.error) {
            BBZINFO(@"视频保存Asset失败：%@, %@", exporter.error, targetPath);
            ret = NO;
        }
        if (ret) {
            [[NSFileManager defaultManager] moveFile:filePath toPath:targetPath replaceIfExist:YES];
        }
        BBZINFO(@"视频保存Asset结束");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(ret, exporter.error);
            }
        });
    }];
    return exporter;
}


+ (CMTime)durationOfAsset:(AVAsset * __nonnull)asset timeRange:(CMTimeRange)timeRange {
    if (asset == nil) {
        return kCMTimeZero;
    }
    
    CMTimeRange wholeTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (videoTrack != nil)  {
        wholeTimeRange = CMTimeRangeGetIntersection(wholeTimeRange, videoTrack.timeRange);
    }
    
    return CMTIMERANGE_IS_VALID(timeRange) ? CMTimeRangeGetIntersection(timeRange, wholeTimeRange).duration : wholeTimeRange.duration;
}

+ (CMTime)durationOfVideoAtPath:(NSString * __nonnull)path timeRange:(CMTimeRange)timeRange {
    if (path == nil) {
        return kCMTimeZero;
    }
    
    return [self durationOfAsset:[AVAsset assetWithURL:[NSURL fileURLWithPath:path]] timeRange:timeRange];
}

+ (CMTime)audioDurationOfAsset:(AVAsset * __nonnull)asset timeRange:(CMTimeRange)timeRange {
    if (asset == nil) {
        return kCMTimeZero;
    }
    
    CMTimeRange wholeTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    if (audioTrack != nil) {
        wholeTimeRange = CMTimeRangeGetIntersection(wholeTimeRange, audioTrack.timeRange);
    }
    
    return CMTIMERANGE_IS_VALID(timeRange) ? CMTimeRangeGetIntersection(timeRange, wholeTimeRange).duration : wholeTimeRange.duration;
}

+ (CGSize)resolutionForVideoSize:(CGSize)videoSize limitedByLongestEdge:(CGFloat)longestEdge {
    if ((videoSize.width > longestEdge) || (videoSize.height > longestEdge))  {
        CGRect aspectFitFrame = AVMakeRectWithAspectRatioInsideRect(videoSize, CGRectMake(0, 0, longestEdge, longestEdge));
        return CGSizeMake((int)aspectFitFrame.size.width, (int)aspectFitFrame.size.height);
    }
    
    return videoSize;
}

+ (CGSize)resolutionForVideoSize:(CGSize)videoSize limitedByResolution:(NSInteger)resolutionLimit {
    CGFloat resolution = videoSize.width * videoSize.height;
    
    if (resolutionLimit < resolution) {
        CGFloat scale = sqrt(resolutionLimit / resolution);
        videoSize.width = videoSize.width * scale;
        videoSize.height = videoSize.height * scale;
    }
    return CGSizeMake([self adjustVideoSizeValue:videoSize.width], [self adjustVideoSizeValue:videoSize.height]);
}

+ (int)adjustVideoSizeValue:(CGFloat)fValue {
    int value = fValue;
    value = value - value % 2;
    return value;
}

@end
