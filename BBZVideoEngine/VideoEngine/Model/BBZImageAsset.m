//
//  BBZImageAsset.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZImageAsset.h"
#import "BBZPhotoKit.h"

@implementation BBZImageAsset
+ (instancetype)assetWithImage:(UIImage *)image;
+ (instancetype)assetWithFilePath:(NSString *)filePath;
+ (instancetype)assetWithPHAsset:(PHAsset *)phasset;
- (void)loadImageWithCompletion:(void (^)(BBZImageAsset *imageItem))completion;
- (void)unloadImage;
@end
