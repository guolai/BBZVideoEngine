//
//  BBZAudioAsset.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZAudioAsset.h"
#import "BBZPhotoKit.h"
#import "BBZVideoTools.h"

@interface BBZAudioAsset ()
@property (nonatomic, strong) AVAsset *avAsset;

@end

@implementation BBZAudioAsset

//- (instancetype)initWithAVAsset:(AVAsset *)avAsset {
//    if([self init]) {
//        _avAsset = avAsset;
//        self.mediaType = BBZBaseAssetMediaTypeAudio;
//        self.filePath = nil;
//        CMTime sourceTimeDuration = [BBZVideoTools durationOfAsset:_avAsset timeRange:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity)];
//        self.sourceTimeRange = CMTimeRangeMake(kCMTimeZero, sourceTimeDuration); ///针对某些特殊视频这样取时间区间还会有问题 后面再看要不要改吧
//        self.playTimeRange = self.sourceTimeRange;
//    }
//    return self;
//}
//
//+ (instancetype)assetWithAVAsset:(AVAsset *)avAsset {
//    BBZAudioAsset *asset = [[BBZAudioAsset alloc] initWithAVAsset:avAsset];
//    return asset;
//}
//
//+ (void)assetWithPHAsset:(PHAsset *)phAsset completion:(void (^)(BBZAudioAsset *videoAsset))completion {
//    [BBZPhotoKit loadAVAssetWithPHAsset:phAsset completion:^(AVAsset *avasset, AVAudioMix *audioMix)
//     {
//        BBZAudioAsset *videoAsset = [BBZAudioAsset assetWithAVAsset:avasset];
//        videoAsset.identifierOfPHAsset = phAsset.localIdentifier;
//        videoAsset.audioMix = audioMix;
//        if (completion)
//        {
//            completion(videoAsset);
//        }
//    }];
//}


- (instancetype)initWithFilePath:(NSString *)filePath {
    if(filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
//        BBZAudioAsset *videoAsset = [[BBZAudioAsset alloc] initWithAVAsset:asset];
//         videoAsset.filePath = filePath;
//        return videoAsset;
    }
    return nil;
}

+ (instancetype)assetWithFilePath:(NSString *)filePath {
    BBZAudioAsset *asset = [[BBZAudioAsset alloc] initWithFilePath:filePath];
    return asset;
}
@end
