//
//  BBZVideoFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZVideoFilterLayer.h"
#import "BBZVideoAction.h"
#import "BBZImageAction.h"


@implementation BBZVideoFilterLayer

- (void)buildTimelineNodes {
    
    if(self.model.transitonModel.spliceGroups.count == 0 &&
       self.model.transitonModel.transitionGroups.count == 0) {
        [self buildTimelineNodeWithoutTrasntion];
    }
}

- (BBZActionBuilderResult *)buildTimelineNodeWithoutTrasntion {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    for (BBZBaseAsset *baseAsset in self.model.assetItems) {
        BBZSourceAction *action = nil;
        if(baseAsset.mediaType == BBZBaseAssetMediaTypeImage) {
            action = [self imageActionWithAsset:(BBZImageAsset *)baseAsset];
        } else if(baseAsset.mediaType == BBZBaseAssetMediaTypeVideo) {
            action = [self videoActionWithAsset:(BBZVideoAsset *)baseAsset];
        }
      
        action.order = builder.groupIndex;
        builder.startTime += baseAsset.playDuration;
        builder.groupIndex++;
        [retArray addObject:action];
    }
    builder.groupActions = retArray;
    return builder;
}

- (BBZActionBuilderResult *)buildTimelineNodeWithTrasntion {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    builder.groupActions = retArray;
    return builder;
}

- (BBZActionBuilderResult *)buildTimeLineSplice {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    if(self.model.transitonModel.spliceGroups.count > 0) {
        
    } else {
        
    }
    
    builder.groupActions = retArray;
    return builder;
}

- (BBZActionBuilderResult *)buildTimeLineTranstion {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    builder.groupActions = retArray;
    return builder;
}


- (BBZImageAction *)imageActionWithAsset:(BBZImageAsset *)asset {
    BBZImageAction *imageAction = [[BBZImageAction alloc] init];
    imageAction.asset = asset;
    imageAction.renderSize = asset.sourceSize;
    imageAction.duration = asset.playDuration;
    return imageAction;
}

- (BBZVideoAction *)videoActionWithAsset:(BBZVideoAsset *)asset {
    BBZVideoAction *videoAction = [[BBZVideoAction alloc] init];
    videoAction.asset = asset;
    videoAction.renderSize = self.context.renderSize;
    videoAction.duration = asset.playDuration;
    return videoAction;
}



@end
