//
//  BBZVideoAsset.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoAsset.h"
#import "BBZVideoTools.h"
#import "BBZPhotoKit.h"

@interface BBZVideoAsset ()
@property (nonatomic, strong) AVAsset *avAsset;

@end

@implementation BBZVideoAsset

- (instancetype)initWithAVAsset:(AVAsset *)avAsset {
    if([self init]) {
        _avAsset = avAsset;
        self.filePath = nil;
        CMTime sourceTimeDuration = [BBZVideoTools durationOfAsset:_avAsset timeRange:CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity)];
        self.sourceTimeRange = CMTimeRangeMake(kCMTimeZero, sourceTimeDuration); ///针对某些特殊视频这样取时间区间还会有问题 后面再看要不要改吧
        self.playTimeRange = self.sourceTimeRange;
    }
    return self;
}

+ (instancetype)assetWithAVAsset:(AVAsset *)avAsset {
    BBZVideoAsset *asset = [[self alloc] initWithAVAsset:avAsset];
    return asset;
}

+ (void)assetWithPHAsset:(PHAsset *)phAsset completion:(void (^)(BBZVideoAsset *videoAsset))completion {
    [BBZPhotoKit loadAVAssetWithPHAsset:phAsset completion:^(AVAsset *avasset, AVAudioMix *audioMix)
     {
        BBZVideoAsset *videoAsset = [BBZVideoAsset assetWithAVAsset:avasset];
        videoAsset.identifierOfPHAsset = phAsset.localIdentifier;
        videoAsset.audioMix = audioMix;
        if (completion)
        {
            completion(videoAsset);
        }
    }];
}

- (NSObject *)asset {
    return _avAsset;
}

#pragma mark - Private


@end
