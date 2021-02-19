//
//  BBZVideoModel.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZImageAsset.h"
#import "BBZVideoAsset.h"
#import "BBZAudioAsset.h"
#import "BBZTransitionModel.h"
#import "BBZFilterModel.h"
#import "BBZTransformItem.h"

@interface BBZVideoModel : NSObject
@property (nonatomic, strong, readonly) NSString *identifier;
/// video and image
@property (nonatomic, strong, readonly) NSArray<BBZBaseAsset *> *assetItems;
@property (nonatomic, strong, readonly) NSArray<BBZAudioAsset *> *audioItems;
@property (nonatomic, strong, readonly) BBZTransitionModel *transitonModel;
@property (nonatomic, strong, readonly) BBZFilterModel *filterModel;
@property (nonatomic, assign, readonly) CGFloat duration;
@property (nonatomic, strong, readonly) NSString *videoResourceDir;
@property (nonatomic, strong) BBZTransformItem *transform;

@property (nonatomic, assign) CGFloat  builderDuraton;
@property (nonatomic, assign) BOOL useOriginAudio;
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, assign) BOOL useGaussImage;//画幅不一致情况下使用高斯模糊
@property (nonatomic, strong) NSArray *maskImage;
@property (nonatomic, assign) CGRect maskImageRect;

//asset
- (BOOL)addVideoSource:(NSString *)filePath;
- (BOOL)addVideoSource:(NSString *)filePath visibleTimeRange:(CMTimeRange)timeRange;
- (BOOL)addVideoAsset:(AVAsset *)avAsset;
- (BOOL)addVideoAsset:(AVAsset *)avAsset visibleTimeRange:(CMTimeRange)timeRange;
- (BOOL)addVideoAsset:(AVAsset *)avAsset videoCompostion:(AVVideoComposition *)videoComposition visibleTimeRange:(CMTimeRange)timeRange;
- (BOOL)addImageSource:(NSString *)filePath;
- (BOOL)addUIImage:(UIImage *)image;

- (BOOL)addAudioSource:(NSString *)filePath;

//filter
- (void)addFilterGroup:(NSString *)strDirectory;
- (void)addTransitionGroup:(NSString *)strDirectory;

////gifFilter
//- (void)addGifFilter:(NSArray *)images
//            atttment:(NSDictionary *)info
//            interval:(CGFloat)fInterval;
//- (void)addMaskFilter:(UIImage *)image frame:(CGRect)frame;

//timeline
- (void)buildTimeLine;
- (NSString *)debugSourceInfo;

@end


