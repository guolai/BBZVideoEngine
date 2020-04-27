//
//  BBZVideoAsset.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZBaseAsset.h"



@interface BBZVideoAsset : BBZBaseAsset
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong, readonly) AVAsset *asset;

- (instancetype)initWithAVAsset:(AVAsset *)avAsset;
+ (instancetype)assetWithAVAsset:(AVAsset *)avAsset;
+ (void)assetWithPHAsset:(PHAsset *)phAsset completion:(void (^)(BBZVideoAsset *videoAsset))completion;

@end

