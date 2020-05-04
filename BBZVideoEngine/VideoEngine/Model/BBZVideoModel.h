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

@interface BBZVideoModel : NSObject
@property (nonatomic, strong, readonly) NSString *identifier;
/// video and image
@property (nonatomic, strong, readonly) NSArray<BBZBaseAsset *> *assetItems;
@property (nonatomic, strong, readonly) NSArray<BBZAudioAsset *> *audioItems;
@property (nonatomic, strong, readonly) BBZTransitionModel *transitonModel;
@property (nonatomic, strong, readonly) BBZFilterModel *filterModel;
@property (nonatomic, assign, readonly) CGFloat duration;
@property (nonatomic, strong, readonly) NSString *videoResourceDir;

@property (nonatomic, strong) BBZImageAsset *bgImageAsset;

//asset
- (BOOL)addVideoSource:(NSString *)filePath;
- (BOOL)addVideoAsset:(AVAsset *)avAsset;
- (BOOL)addImageSource:(NSString *)filePath;
- (BOOL)addUIImage:(UIImage *)image;

//filter
- (void)addFilterGroup:(NSString *)strDirectory;
- (void)addTransitionGroup:(NSString *)strDirectory;


//timeline
- (void)buildTimeLine;

@end


