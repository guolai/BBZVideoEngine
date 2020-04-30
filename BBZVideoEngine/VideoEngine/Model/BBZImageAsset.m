//
//  BBZImageAsset.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZImageAsset.h"
#import "BBZPhotoKit.h"
#import "BBZVideoTools.h"
#import "BBZEngineSetting.h"

@interface BBZImageAsset ()
@property (nonatomic, strong) UIImage *sourceimage;
@property (nonatomic, assign) BOOL bFullResolution;
@end

//@property (nonatomic, assign) NSTimeInterval sourceDuration;
//@property (nonatomic, assign) CMTimeRange sourceTimeRange;
//@property (nonatomic, assign) NSTimeInterval playDuration;
//@property (nonatomic, assign) CMTimeRange playTimeRange;

@implementation BBZImageAsset
//@synthesize sourceimage = _sourceimage;
@synthesize bFullResolution = _bFullResolution;

- (instancetype)init {
    if (self = [super init]) {
        
        self.sourceTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(2 * BBZVideoTimeScale, BBZVideoTimeScale));
        self.playTimeRange = self.sourceTimeRange;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    if(filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        BBZImageAsset *imageAsset = [[BBZImageAsset alloc] init];
        imageAsset.filePath = filePath;
        return imageAsset;
    }
    NSAssert(false, @"invalid filepath");
    return nil;
}

+ (instancetype)assetWithFilePath:(NSString *)filePath {
    BBZImageAsset *asset = [[BBZImageAsset alloc] initWithFilePath:filePath];
    return asset;
}

- (instancetype)initWithImage:(UIImage *)image {
    if([self init]) {
        _sourceimage = image;
    }
    return self;
}

+ (instancetype)assetWithImage:(UIImage *)image {
    BBZImageAsset *imageAsset = [[BBZImageAsset alloc] initWithImage:image];
    return imageAsset;
}

+ (instancetype)assetWithPHAsset:(PHAsset *)phasset {
    BBZImageAsset *imageAsset = [[BBZImageAsset alloc] init];
    imageAsset.identifierOfPHAsset = phasset.localIdentifier;
    return imageAsset;
}

- (void)loadImageWithCompletion:(void (^)(BBZImageAsset *imageItem))completion {
    if (_sourceimage != nil) {
        if (completion) {
            completion(self);
        }
        return;
    }
    
    if (self.filePath != nil) {
        NSData *data = [NSData dataWithContentsOfFile:self.filePath];
        _sourceimage = [UIImage imageWithData:data];
        _bFullResolution = YES;
        if (completion) {
            completion(self);
        }
        return;
    }
    
    if (self.identifierOfPHAsset != nil) {
        PHAsset *asset = [BBZPhotoKit PHAssetWithIdentifier:self.identifierOfPHAsset];
        CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        if(self.bUserOriginalSize) {
        } else {
            NSInteger limit = [BBZEngineSetting perfectResolutionForImage];
            size = [BBZVideoTools resolutionForVideoSize:size limitedByResolution:limit];
        }
    
        BOOL isFullResolution = (size.width * size.height) > (asset.pixelWidth * asset.pixelHeight - 1);
        [BBZPhotoKit loadImageWithPHAsset:asset size:size completion:^(UIImage *image)  {
            self.sourceimage = image;
            self.bFullResolution = isFullResolution;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)unloadImage {
    if (self.filePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        self.sourceimage = nil;
        self.bFullResolution = NO;
    }
}

- (UIImage *)asset {
    if(!self.sourceimage) {
        if (self.filePath != nil)  {
            NSData *data = [NSData dataWithContentsOfFile:self.filePath];
            self.sourceimage = [UIImage imageWithData:data];
            self.bFullResolution = YES;
            NSAssert(_sourceimage, @"filtpath exsit, image is lost");
        }
    }
    return self.sourceimage;
}

@end
