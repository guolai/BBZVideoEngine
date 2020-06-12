//
//  BBZEngineSetting.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZEngineSetting.h"
#import "UIDevice+BBZ.h"


@implementation BBZEngineSetting


+ (instancetype)passthroughVideoSettings {
    BBZEngineSetting *videoSettings = [[BBZEngineSetting alloc] init];
    videoSettings.passthroughPresetName = AVAssetExportPresetPassthrough;
    return videoSettings;
}
+ (instancetype)engineSettingsWithPassthroughPresetName:(NSString *)presetName {
    BBZEngineSetting *videoSettings = [[BBZEngineSetting alloc] init];
    videoSettings.passthroughPresetName = presetName;
    return videoSettings;
}

- (void)setVideoSize:(CGSize)videoSize {
    _videoSize = videoSize;
    _videoLongestEdge = MAX(_videoSize.width, _videoSize.height);
}

- (NSDictionary *)videoOutputSettings {
    if ((_videoSize.width < 1) || (_videoSize.height < 1))  {
        return nil;
    }
    
    NSMutableDictionary *compression = [NSMutableDictionary dictionary];
    compression[AVVideoProfileLevelKey] = _profileLevel ? : AVVideoProfileLevelH264HighAutoLevel;
    compression[AVVideoMaxKeyFrameIntervalKey] = @(250);

    if (_videoBitRate > 0) {
        compression[AVVideoAverageBitRateKey] = @((CGFloat)_videoBitRate);
    }
    
    compression[AVVideoExpectedSourceFrameRateKey] = @(_videoFrameRate);
//    compression[AVVideoAllowFrameReorderingKey] = @(_allowFrameReorder);
    compression[AVVideoAllowFrameReorderingKey] = @(NO);
    
    return @{AVVideoCodecKey: AVVideoCodecH264,
             AVVideoWidthKey: @((NSInteger)_videoSize.width),
             AVVideoHeightKey: @((NSInteger)_videoSize.height),
             AVVideoCompressionPropertiesKey: compression};
}

- (NSDictionary *)audioOutputSettings {
    if ((_audioSampleRate < 1) || (_audioBitRate < 1)) {
        return nil;
    }
    
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSData *channelLayoutAsData = [NSData dataWithBytes:&acl length:sizeof(acl)];
    
    return @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
             AVSampleRateKey: @(_audioSampleRate),
             AVEncoderBitRateKey: @(_audioBitRate),
             AVChannelLayoutKey: channelLayoutAsData,
             AVNumberOfChannelsKey: @(2)};
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<BBZEngineSetting %p>:\r", self];
    [string appendFormat:@"videoOutputSettings: %@\r", [self videoOutputSettings]];
    [string appendFormat:@"audioOutputSettings: %@\r", [self audioOutputSettings]];
    return string;
}

#pragma mark -  Helper

+ (NSInteger)perfectAudioBitRate {
    return 128 * 1000;
}

+ (NSInteger)perfectVideoBitRate {
    return 5 * 1024 * 1024;
}


+ (CGSize)perfectRenderSize {
    if ([UIDevice getDeviceLevel] == kBBZDeviceLeveliPhone6p) {
       return CGSizeMake(450.0, 800);
    }
    else if ([UIDevice getDeviceLevel] < kBBZDeviceLeveliPhoneSE) {
        return CGSizeMake(540.0, 960.0);
    }
    else if ([UIDevice getDeviceLevel] < kBBZDeviceLeveliPhone7) {
        return CGSizeMake(720., 1280.);
    }
    return CGSizeMake(1080., 1920.);
}

+ (NSInteger)perfectResolutionForRenderSize {
    CGSize renderSize = [BBZEngineSetting perfectRenderSize];
    return renderSize.width * renderSize.height;
}

+ (NSInteger)maxResolution {
    return 1080 * 1920 * 1.2;
}


+ (CGSize)perfectImageSize {
    if ([UIDevice getDeviceLevel] == kBBZDeviceLeveliPhone6p) {
        return CGSizeMake(450.0, 800);
    }
    else if ([UIDevice getDeviceLevel] < kBBZDeviceLeveliPhoneSE) {
        return CGSizeMake(540.0, 960.0);
    }
    else if ([UIDevice getDeviceLevel] < kBBZDeviceLeveliPhone7) {
        return CGSizeMake(720., 1280.);
    }
    return CGSizeMake(1080., 1920.);
}

+ (NSInteger)perfectResolutionForImage {
    CGSize renderSize = [BBZEngineSetting perfectRenderSize];
    return renderSize.width * renderSize.height;
}

+ (NSInteger)maxResolutionForImage {
    return 1080 * 1920;
}

@end
