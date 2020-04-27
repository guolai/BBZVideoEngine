//
//  BBZImageAsset.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/18.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZBaseAsset.h"


@interface BBZImageAsset : BBZBaseAsset
@property (nonatomic, assign) BOOL bUserOriginalSize;//有些图片不需要进行拉金伸 比如一些图标
@property (nonatomic, strong, readonly) UIImage *sourceimage;
@property (nonatomic, assign, readonly) BOOL bFullResolution;

+ (instancetype)assetWithImage:(UIImage *)image;
+ (instancetype)assetWithPHAsset:(PHAsset *)phasset;
- (void)loadImageWithCompletion:(void (^)(BBZImageAsset *imageItem))completion;
- (void)unloadImage;


@end


