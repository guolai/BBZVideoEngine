//
//  BBZPhotoKit.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZPhotoKit.h"
#import "NSError+BBZ.h"

@implementation BBZPhotoKit
+ (PHAsset *)PHAssetWithIdentifier:(NSString *)identifier {
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:[[PHFetchOptions alloc] init]];
    return result.firstObject;
}

+ (void)checkStorageForPHAsset:(PHAsset *)asset completion:(void (^)(BOOL iCloud))completion {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        completion((asset == nil));
    }];
}

+ (PHImageRequestID)loadAVAssetWithPHAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix))completion {
    if (asset.mediaType != PHAssetMediaTypeVideo) {
        if (completion) {
            completion(nil, nil);
        }
        return 0;
    }
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    return [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if (completion) {
            completion(asset, audioMix);
        }
    }];
}

+ (PHImageRequestID)loadImageWithPHAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *image))completion {
    if (asset.mediaType != PHAssetMediaTypeImage) {
        if (completion) {
            completion(nil);
        }
        return 0;
    }
    
    if ((size.width < 1) || (size.height < 1)) {
        size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    return [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info)  {
        NSNumber *degraded = info[PHImageResultIsDegradedKey];
        if (degraded && ([degraded boolValue] == NO)) {
            if (completion) {
                completion(result);
            }
        }
    }];
}

+ (PHImageRequestID)loadImageWithPHAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion {
    return [self loadImageWithPHAsset:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) completion:completion];
}

+ (PHImageRequestID)loadAVAssetWithPHAssetIdentifier:(NSString *)identifier completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix))completion {
    if (identifier != nil) {
        PHAsset *phAsset = [self PHAssetWithIdentifier:identifier];
        if (phAsset != nil) {
            return [self loadAVAssetWithPHAsset:phAsset completion:completion];
        }
    }
    
    if (completion) {
        completion(nil, nil);
    }
    
    return 0;
}
@end
