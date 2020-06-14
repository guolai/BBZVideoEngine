//
//  BBZAudioAsset.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZBaseAsset.h"



@interface BBZAudioAsset : BBZBaseAsset
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong, readonly) AVAsset *asset;
@end


