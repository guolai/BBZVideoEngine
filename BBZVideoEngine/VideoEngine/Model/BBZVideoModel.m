//
//  BBZVideoModel.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoModel.h"
#import "NSFileManager+BBZTools.h"


@interface BBZVideoModel ()
@property (nonatomic, strong) NSMutableArray<BBZBaseAsset *> *interAssetItems;
@property (nonatomic, strong) NSMutableArray<BBZAudioAsset *> * _Nullable interAudioItems;
@property (nonatomic, strong, readwrite) NSString *videoResourceDir;

@end

@implementation BBZVideoModel

- (instancetype)init {
    if(self = [super init]){
        _identifier = [NSString stringWithFormat:@"Model%.6f-%li",[NSDate timeIntervalSinceReferenceDate], (long)arc4random()];
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        NSString *baseDir = [cacheDir stringByAppendingPathComponent:@"VideoModel"];
        _interAssetItems = [NSMutableArray array];
        _interAudioItems = [NSMutableArray array];
        _videoResourceDir = [NSString stringWithFormat:@"%@/%@", baseDir, _identifier];
//        _transform = CGAffineTransformIdentity;
        _useOriginAudio = YES;
        [NSFileManager createDirIfNeed:_videoResourceDir];
    }
    return self;
}


#pragma mark - Asset
- (BOOL)addVideoSource:(NSString *)filePath {
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    BBZVideoAsset *videoAsset = [BBZVideoAsset assetWithAVAsset:avAsset];
    [self.interAssetItems addObject:videoAsset];
    return YES;
}

- (BOOL)addVideoSource:(NSString *)filePath visibleTimeRange:(CMTimeRange)timeRange {
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    BBZVideoAsset *videoAsset = [BBZVideoAsset assetWithAVAsset:avAsset];
    videoAsset.playTimeRange = timeRange;
    [self.interAssetItems addObject:videoAsset];
    return YES;
}



- (BOOL)addVideoAsset:(AVAsset *)avAsset {
    BBZVideoAsset *videoAsset = [BBZVideoAsset assetWithAVAsset:avAsset];
    [self.interAssetItems addObject:videoAsset];
    return YES;
}

- (BOOL)addVideoAsset:(AVAsset *)avAsset visibleTimeRange:(CMTimeRange)timeRange {
    BBZVideoAsset *videoAsset = [BBZVideoAsset assetWithAVAsset:avAsset];
    videoAsset.playTimeRange = timeRange;
    [self.interAssetItems addObject:videoAsset];
    return YES;
}

- (BOOL)addVideoAsset:(AVAsset *)avAsset videoCompostion:(AVVideoComposition *)videoComposition visibleTimeRange:(CMTimeRange)timeRange {
    BBZVideoAsset *videoAsset = [BBZVideoAsset assetWithAVAsset:avAsset];
    videoAsset.playTimeRange = timeRange;
    videoAsset.videoCompostion = videoComposition;
    [self.interAssetItems addObject:videoAsset];
    return YES;
}

- (BOOL)addImageSource:(NSString *)filePath {
    BBZImageAsset *imageAsset = [BBZImageAsset assetWithFilePath:filePath];
    [self.interAssetItems addObject:imageAsset];
    return YES;
}

- (BOOL)addUIImage:(UIImage *)image {
    BBZImageAsset *imageAsset = [BBZImageAsset assetWithImage:image];
    [self.interAssetItems addObject:imageAsset];
    return YES;
}

- (BOOL)addAudioSource:(NSString *)filePath {
    BBZAudioAsset *audioAsset = [BBZAudioAsset assetWithFilePath:filePath];
    [self.interAudioItems addObject:audioAsset];
    return YES;
}


- (NSArray *)assetItems {
    return self.interAssetItems;
}

- (NSArray *)audioItems {
    return self.interAudioItems;
}

- (NSString *)debugSourceInfo {
    NSMutableString *mutableString = [NSMutableString string];
    NSUInteger imageCount = 0;
    NSUInteger videoCount = 0;
    for (BBZBaseAsset *baseAsset in self.interAssetItems) {
        if(baseAsset.mediaType == BBZBaseAssetMediaTypeImage) {
            imageCount++;
        } else {
            videoCount++;
        }
    }
    
    NSString *str = [NSString stringWithFormat:@"视频:%lu个,图片:%lu个,", (unsigned long)videoCount, imageCount];
    [mutableString appendString:str];
    str = [NSString stringWithFormat:@"音频:%lu个", self.audioItems.count];
    [mutableString appendString:str];
    return mutableString;
}

#pragma mark - Filter

- (void)addFilterGroup:(NSString *)strDirectory {
    _filterModel = [[BBZFilterModel alloc] initWidthDir:strDirectory];
}

- (void)addTransitionGroup:(NSString *)strDirectory {
    _transitonModel = [[BBZTransitionModel alloc] initWidthDir:strDirectory];
}


//- (void)addGifFilter:(NSArray *)images
//               atttment:(NSDictionary *)info
//            interval:(CGFloat)fInterval {
//    [self checkFilterModel];
//    BBZFilterNode *filterNode = _filterModel.filterGroups.firstObject;
//    
//    NSMutableArray *actions = [NSMutableArray arrayWithArray:filterNode.actions];
//    BBZNode *node = [BBZNode createLocalNode:BBZNodeOverLayImage duration:100000.0];
//    node.attachmentInfo = info;
//    [actions addObject:node];
//    filterNode.actions = actions;
//    node.images = images;
//    node.fInterval = fmax(0.05, fInterval);
//    
//}
//
//- (void)addMaskFilter:(UIImage *)image  frame:(CGRect)frame{
//    [self checkFilterModel];
//    BBZFilterNode *filterNode = _filterModel.filterGroups.firstObject;
//    NSMutableArray *actions = [NSMutableArray arrayWithArray:filterNode.actions];
//    BBZNode *node = [BBZNode createLocalNode:BBZNodeBlendImage duration:100000.0];
//    [actions addObject:node];
//    filterNode.actions = actions;
//    node.images = @[image];
//    [node buildBlendFrame:frame];
//    node.fInterval = 100;
//}

- (void)checkFilterModel {
    if(_filterModel) {
        return;
    }
    _filterModel = [[BBZFilterModel alloc] initWidthDir:nil];
    BBZFilterNode *filterNode = [[BBZFilterNode alloc] initWithDictionary:nil withFilePath:nil];
    filterNode.begin = 0.0;
    filterNode.duration = 10000.0;
    _filterModel.filterGroups = @[filterNode];
}

#pragma mark - Timeline
- (void)buildTimeLine{
    
}



@end
