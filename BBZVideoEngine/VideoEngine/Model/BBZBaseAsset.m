//
//  BBZBaseAsset.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZBaseAsset.h"



@interface BBZBaseAsset ()

@end

@implementation BBZBaseAsset
@synthesize filePath = _filePath;

- (instancetype)init {
    if(self = [super init]){
        _identifier = [NSString stringWithFormat:@"Asset-%.6f-%li", [NSDate timeIntervalSinceReferenceDate], (NSInteger)arc4random()];
        _sourceTimeRange = kCMTimeRangeZero;
        _transform = CGAffineTransformIdentity;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    if([self init]) {
        _filePath = filePath;
//        _asset = nil;
    }
    return self;
}


+ (instancetype)assetWithFilePath:(NSString *)filePath {
    BBZBaseAsset *asset = [[self  alloc] initWithFilePath:filePath];
    return asset;
}

#pragma mark - Proerty

- (void)setSourceTimeRange:(CMTimeRange)sourceTimeRange {
    _sourceTimeRange = sourceTimeRange;
    _sourceDuration = CMTimeGetSeconds(_sourceTimeRange.duration);
}

- (void)setPlayTimeRange:(CMTimeRange)playTimeRange {
    _playTimeRange = playTimeRange;
    _playDuration = CMTimeGetSeconds(_playTimeRange.duration);
}

@end
