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

@implementation BBZImageAsset
@synthesize sourceimage = _sourceimage;
@synthesize bFullResolution = _bFullResolution;

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
        NSInteger limit = [BBZEngineSetting perfectResolutionForImage];
        CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        size = [BBZVideoTools resolutionForVideoSize:size limitedByResolution:limit];
        BOOL isFullResolution = (size.width * size.height) > (asset.pixelWidth * asset.pixelHeight - 1);
        
        [BBZPhotoKit loadImageWithPHAsset:asset size:size completion:^(UIImage *image)  {
            self->_sourceimage = image;
            self->_bFullResolution = isFullResolution;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)unloadImage {
    if (self.filePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        _sourceimage = nil;
        _bFullResolution = NO;
    }
}

- (UIImage *)sourceimage {
    if(!_sourceimage) {
        if (self.filePath != nil)  {
            NSData *data = [NSData dataWithContentsOfFile:self.filePath];
            _sourceimage = [UIImage imageWithData:data];
            _bFullResolution = YES;
            NSAssert(_sourceimage, @"filtpath exsit, image is lost");
        }
    }
    return _sourceimage;
}

@end
