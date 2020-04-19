//
//  BBZPhotoKit.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBZPhotoKit : NSObject
+ (PHAsset *)PHAssetWithIdentifier:(NSString *)identifier;

+ (void)checkStorageForPHAsset:(PHAsset *)asset completion:(void (^)(BOOL iCloud))completion;

+ (PHImageRequestID)loadAVAssetWithPHAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix))completion;

+ (PHImageRequestID)loadImageWithPHAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *image))completion;

+ (PHImageRequestID)loadImageWithPHAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion;

+ (PHImageRequestID)loadAVAssetWithPHAssetIdentifier:(NSString *)identifier completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix))completion;
@end

NS_ASSUME_NONNULL_END
