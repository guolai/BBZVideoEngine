//
//  BBZEngineSetting+VideoModel.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/26.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZEngineSetting+VideoModel.h"
#import "BBZVideoTools.h"


@implementation BBZEngineSetting (VideoModel)

- (BBZEngineSetting *)buildVideoSettings:(BBZVideoModel *)videoModel {
    NSArray *assetItems = videoModel.assetItems;
    
    NSMutableArray *array = [NSMutableArray array];
    for (BBZBaseAsset *baseAsset in assetItems) {
        if(baseAsset.mediaType == BBZBaseAssetMediaTypeVideo) {
            BBZVideoAsset *videoAsset = (BBZVideoAsset *)baseAsset;
            BBZEngineSetting *settings = [BBZEngineSetting videoSettingsForVideoAsset:videoAsset];
            [array addObject:settings];
        } else if(baseAsset.mediaType == BBZBaseAssetMediaTypeImage) {
            BBZImageAsset *imageAsset = (BBZImageAsset *)baseAsset;
            BBZEngineSetting *settings = [BBZEngineSetting videoSettingsForImageAsset:imageAsset];
            [array addObject:settings];
        }
    }
    BBZEngineSetting *videoSettings = [[BBZEngineSetting alloc] init];
    videoSettings.audioSampleRate = 48000;
    videoSettings.audioBitRate = [BBZEngineSetting audioBitRateForVideoSettingsArray:array];
    videoSettings.videoBitRate = [BBZEngineSetting videoBitRateForVideoSettingsArray:array];
    videoSettings.videoFrameRate = [BBZEngineSetting videoFrameRateForVideoSettingsArray:array];
    videoSettings.videoSize = [BBZEngineSetting videoSizeForVideoSettingsArray:array aspectRatio:[BBZEngineSetting aspectRatioForVideoSettingsArray:array]];
    
    videoSettings.videoBitRate = MIN(videoSettings.videoBitRate, [BBZEngineSetting perfectVideoBitRate]);
    videoSettings.audioBitRate = MIN(videoSettings.audioBitRate, [BBZEngineSetting perfectAudioBitRate]);
    
    videoSettings.videoBitRate = MAX(videoSettings.videoBitRate, [BBZEngineSetting minVideoBitRate]);
    videoSettings.audioBitRate = MAX(videoSettings.audioBitRate, [BBZEngineSetting minAudioBitRate]);
    
    return videoSettings;
}


+ (BBZEngineSetting *)videoSettingsForVideoAsset:(BBZVideoAsset *)videoAsset {
    NSInteger videoBitRate = 0;
    NSInteger videoFrameRate = 0;
    NSInteger audioBitRate = 0;
    NSInteger audioSampleRate = 48000;
    CGSize videoSize = CGSizeZero;
    
    [BBZVideoTools readAVAsset:videoAsset.asset forVideoSize:&videoSize videoBitRate:&videoBitRate frameRate:&videoFrameRate audioBitRate:&audioBitRate];
    
    BBZEngineSetting *settings = [[BBZEngineSetting alloc] init];
    settings.videoSize = videoSize;
    settings.videoBitRate = videoBitRate;
    settings.videoFrameRate = videoFrameRate;
    settings.audioBitRate = audioBitRate;
    settings.audioSampleRate = audioSampleRate;
    
    settings.videoBitRate = MIN(settings.videoBitRate, [BBZEngineSetting perfectVideoBitRate]);
    settings.audioBitRate = MIN(settings.audioBitRate, [BBZEngineSetting perfectAudioBitRate]);
    
    return settings;
}


+ (BBZEngineSetting *)videoSettingsForImageAsset:(BBZImageAsset *)imageAsset {
    BBZEngineSetting *settings = [[BBZEngineSetting alloc] init];
    CGSize imageSize = imageAsset.asset.size;
    if(imageAsset.bUserOriginalSize && !CGSizeEqualToSize(imageSize, CGSizeZero)) {
        settings.videoSize = imageSize;
    } else {
        settings.videoSize = [BBZEngineSetting perfectImageSize];
    }
    settings.videoFrameRate = 30;
    return settings;
}

+ (NSInteger)videoFrameRateForVideoSettingsArray:(NSArray *)videoSettingsArray {
    NSInteger maximumFrameRate = 0;
    
    for (BBZEngineSetting *settings in videoSettingsArray) {
        if (settings.videoFrameRate > maximumFrameRate) {
            maximumFrameRate = settings.videoFrameRate;
        }
    }
    return maximumFrameRate;
}

+ (NSInteger)audioBitRateForVideoSettingsArray:(NSArray *)videoSettingsArray {
    NSInteger maximumAudioBitRate = 0;
     ///取所有音频最大码率
    for (BBZEngineSetting *settings in videoSettingsArray) {
        if (settings.audioBitRate > maximumAudioBitRate) {
            maximumAudioBitRate = settings.audioBitRate;
        }
    }
    return maximumAudioBitRate;
}

+ (NSInteger)videoBitRateForVideoSettingsArray:(NSArray *)videoSettingsArray {
    NSInteger maximumVideoBitRate = 0;
    ///取所有视频最大码率
    for (BBZEngineSetting *settings in videoSettingsArray) {
        if (settings.videoBitRate > maximumVideoBitRate) {
            maximumVideoBitRate = settings.videoBitRate;
        }
    }
    return maximumVideoBitRate;
}

+ (CGFloat)aspectRatioForVideoSettingsArray:(NSArray *)videoSettingsArray {
    CGFloat aspectRatio = 0;
    CGFloat aspectRatioTmp;
    CGFloat aspectRatioOffset = MAXFLOAT;
    CGFloat aspectRatioOffsetTmp;
    CGFloat standardAspectRatio = 9.0 / 16.0;
    
    //找出最接近standardAspectRatio的视频分辨率，以及视频的最高尺寸
    for (BBZEngineSetting *settings in videoSettingsArray) {
        if ((settings.videoSize.width < 1) && (settings.videoSize.height < 1)) {
            BBZERROR(@"invalid videosize");
            continue;
        }
        
        aspectRatioTmp = settings.videoSize.width / settings.videoSize.height;
        aspectRatioOffsetTmp = fabs(aspectRatioTmp - standardAspectRatio);
        
        if (aspectRatioOffsetTmp < aspectRatioOffset) {
            aspectRatio = aspectRatioTmp;
            aspectRatioOffset = aspectRatioOffsetTmp;
        }
    }
    return aspectRatio;
}

+ (CGSize)videoSizeForVideoSettingsArray:(NSArray *)videoSettingsArray aspectRatio:(CGFloat)aspectRatio {
    if (aspectRatio < 0.001) {
        return CGSizeZero;
    }
    
    CGSize maximumSize = CGSizeZero;

    for (BBZEngineSetting *settings in videoSettingsArray) {
        if (settings.videoSize.height > maximumSize.height) {
            maximumSize.height = settings.videoSize.height;
        }
        if (settings.videoSize.width > maximumSize.width)  {
            maximumSize.width = settings.videoSize.width;
        }
    }
    CGSize videoSize = CGSizeZero;
    if(aspectRatio <= 1) {
        videoSize = CGSizeMake(maximumSize.height * aspectRatio, maximumSize.height);
    } else {
        videoSize = CGSizeMake(maximumSize.width, (maximumSize.width / aspectRatio));
    }
    if ((videoSize.width < 1) || (videoSize.height < 1)) {
         BBZERROR(@"invalid videosize");
        return videoSize;
    }
    
    CGFloat width = MAX(1, ((int)videoSize.width / 2)) * 2;
    CGFloat height = MAX(1, ((int)videoSize.height / 2)) * 2;
    videoSize = CGSizeMake(width, height);

    return videoSize;
}

@end
