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
#import "BBZInputFilterAction.h"


@implementation BBZVideoFilterLayer

- (void)buildTimelineNodes {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    if(self.model.transitonModel.spliceGroups.count == 0 &&
       self.model.transitonModel.transitionGroups.count == 0) {
        [self buildTimelineNodeWithoutTrasntion];
    } else {
        [self buildTimelineNodeWithTrasntion];
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
        action.startTime = builder.startTime;
        action.order = builder.groupIndex;
        
        builder.startTime += baseAsset.playDuration;
        builder.groupIndex++;
        builder.assetIndex++;
        BBZActionTree *actionTree = [BBZActionTree createActionTreeWithAction:action];
        
        BBZInputFilterAction *filterAction = [[BBZInputFilterAction alloc] init];
        filterAction.startTime = action.startTime;
        filterAction.duration = action.duration;
        BBZActionTree *filterTree = [BBZActionTree createActionTreeWithAction:filterAction];
        [filterTree addSubTree:actionTree];
        
        [retArray addObject:filterTree];
    }
    builder.groupActions = retArray;
    return builder;
}

- (BBZActionBuilderResult *)buildTimelineNodeWithTrasntion {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    BBZActionBuilderResult *spliceBuilder = [self buildTimeLineSplice];
    builder.groupActions = retArray;
    return builder;
}

- (BBZActionBuilderResult *)buildTimeLineSplice {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSUInteger spliceIndex = 0;
    NSUInteger playDuration = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    if(self.model.transitonModel.spliceGroups.count > 0) {
        while (builder.assetIndex < self.model.assetItems.count) {
            if(spliceIndex >= self.model.transitonModel.spliceGroups.count) {
                spliceIndex = 0;
            }
            
            BBZSpliceGroupNode *splice = [self.model.transitonModel.spliceGroups objectAtIndex:spliceIndex];
            playDuration = splice.minDuration * BBZVideoDurationScale;
            NSMutableArray *sourceArray = [NSMutableArray array];
            NSMutableArray *inputArray = [NSMutableArray array];
            for (BBZInputNode *input in splice.inputNodes) {
                NSInteger assetIndex = builder.assetIndex + input.assetOrder;
                
                if(assetIndex > self.model.assetItems.count) { //使用上一轮的当前位置显示的图片
                    assetIndex = assetIndex - splice.inputNodes.count;
                    if(assetIndex < 0) {
                        assetIndex = 0;
                    }
                }
                BBZBaseAsset *baseAsset = [self.model.assetItems objectAtIndex:assetIndex];
                playDuration = MAX(baseAsset.playDuration, playDuration);
                
                //构建source action
                BBZSourceAction *action = nil;
                if(baseAsset.mediaType == BBZBaseAssetMediaTypeImage) {
                    action = [self imageActionWithAsset:(BBZImageAsset *)baseAsset];
                } else if(baseAsset.mediaType == BBZBaseAssetMediaTypeVideo) {
                    action = [self videoActionWithAsset:(BBZVideoAsset *)baseAsset];
                }
                action.order = input.index;
                [sourceArray addObject:baseAsset];
                
            }
            
            int i = 0;
            for (BBZInputNode *input in splice.inputNodes) {
                
                BBZSourceAction *action = nil;
                if(baseAsset.mediaType == BBZBaseAssetMediaTypeImage) {
                    action = [self imageActionWithAsset:(BBZImageAsset *)baseAsset];
                } else if(baseAsset.mediaType == BBZBaseAssetMediaTypeVideo) {
                    action = [self videoActionWithAsset:(BBZVideoAsset *)baseAsset];
                }
                
                action.order = builder.groupIndex;
                
                BBZActionTree *actionTree = [BBZActionTree createActionTreeWithAction:action];
                
                BBZInputFilterAction *filterAction = [[BBZInputFilterAction alloc] init];
                filterAction.startTime = action.startTime;
                filterAction.duration = action.duration;
                BBZActionTree *filterTree = [BBZActionTree createActionTreeWithAction:filterAction];
                [filterTree addSubTree:actionTree];
            }
            
            BBZActionTree *spliceTree = [self actionTreeWithSpliceNode:splice.spliceNode];
            
            builder.assetIndex += splice.inputNodes.count;
            builder.startTime += 
            spliceIndex ++;
        }
    } else {
        
    }
    builder.groupIndex++;
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

- (BBZActionTree *)actionTreeWithSpliceNode:(BBZSpliceNode *)spliceNode {
    BBZActionTree *spliceTree = nil;
//    BBZFilterAction *filterAction = [[BBZFilterAction alloc] init];
//    filterAction.node = splice.spliceNode;
    return spliceTree;
}

@end
