//
//  BBZVideoFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZVideoFilterLayer.h"
#import "BBZVideoSourceAction.h"
#import "BBZImageSourceAction.h"
#import "BBZInputFilterAction.h"
#import "BBZVideoReaderAction.h"


@implementation BBZVideoFilterLayer

- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    BBZActionBuilderResult *builder = nil;
    if(self.model.transitonModel.spliceGroups.count == 0) {
       builder = [self buildDefaultTimeline];
    } else {
       builder = [self buildSpliceTimeline];
    }
    return builder;
}

- (BBZActionBuilderResult *)buildDefaultTimeline {
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

/*
    假设splice的最短时长 2秒
    某一段资源前后转场两次相加的时长 不能超过2秒
 */
- (BBZActionBuilderResult *)buildSpliceTimeline {
    BBZActionBuilderResult *builder = nil;
    if(self.model.transitonModel.spliceGroups.count > 0) {
        builder = [self buildTimeLineWithSpliceNodes];
    } else  {
        builder = [self buildDefaultTimeline];
    }
    return builder;
}

- (BBZActionBuilderResult *)buildTimeLineWithSpliceNodes {
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSUInteger spliceIndex = 0;
    NSUInteger playDuration = 0;
    NSMutableArray *retArray = [NSMutableArray array];
 
    while (builder.assetIndex < self.model.assetItems.count) {
        if(spliceIndex >= self.model.transitonModel.spliceGroups.count) {
            spliceIndex = 0;
        }
        
        BBZSpliceGroupNode *splice = [self.model.transitonModel.spliceGroups objectAtIndex:spliceIndex];
        playDuration = splice.minDuration * BBZVideoDurationScale;
        NSMutableArray *sourceArray = [NSMutableArray array];
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
            action.scale = input.scale;
            action.order = input.index;
            [sourceArray addObject:action];
            
        }

        BBZActionTree *spliceTree = [self actionTreeWithSpliceNode:splice.spliceNode duration:playDuration startTime:builder.startTime];
        int i = 0;
        for (BBZInputNode *input in splice.inputNodes) {
            BBZSourceAction *sourceAction = [sourceArray objectAtIndex:i];
            sourceAction.startTime = builder.startTime;
            sourceAction.duration = playDuration;
            
            BBZActionTree *actionTree = [BBZActionTree createActionTreeWithAction:sourceAction];
            
            BBZInputFilterAction *filterAction = [[BBZInputFilterAction alloc] init];
            filterAction.startTime = sourceAction.startTime;
            filterAction.duration = sourceAction.duration;
            BBZActionTree *filterTree = [BBZActionTree createActionTreeWithAction:filterAction];
            [filterTree addSubTree:actionTree];
            
            BBZActionTree *inputActionTree = [self actionTreeWithInputNode:input duration:playDuration startTime:builder.startTime];
            [inputActionTree addSubTree:filterTree];
            [spliceTree addSubTree:inputActionTree];
            i++;
        }
        [retArray addObject:spliceTree];
    
        
        builder.startTime += playDuration;
        builder.groupIndex++;
        builder.assetIndex += splice.inputNodes.count;

        spliceIndex ++;
    }

    builder.groupActions = retArray;
    return builder;
}


- (BBZImageSourceAction *)imageActionWithAsset:(BBZImageAsset *)asset {
    BBZImageSourceAction *imageAction = [[BBZImageSourceAction alloc] init];
    imageAction.asset = asset;
    imageAction.renderSize = asset.sourceSize;
    imageAction.duration = asset.playDuration;
    return imageAction;
}

- (BBZVideoSourceAction *)videoActionWithAsset:(BBZVideoAsset *)asset {
    BBZVideoReaderAction *videoAction = [[BBZVideoReaderAction alloc] init];
    videoAction.asset = asset;
    videoAction.renderSize = self.context.renderSize;
    videoAction.duration = asset.playDuration;
    return videoAction;
}

- (BBZActionTree *)actionTreeWithSpliceNode:(BBZSpliceNode *)spliceNode
                                   duration:(NSUInteger)duration
                                  startTime:(NSUInteger)startTime{
    BBZActionTree *spliceTree = [[BBZActionTree alloc] init];
    for (BBZNode *node in spliceNode.actions) {
        BBZFilterAction *filterAction = [[BBZFilterAction alloc] initWithNode:node];
        filterAction.startTime = startTime;
        filterAction.duration = duration;
        [spliceTree addAction:filterAction];
    }
   
    return spliceTree;
}

- (BBZActionTree *)actionTreeWithInputNode:(BBZInputNode *)inputNode
                                  duration:(NSUInteger)duration
                                 startTime:(NSUInteger)startTime{
    BBZActionTree *inputTree = [[BBZActionTree alloc] init];
    for (BBZNode *node in inputNode.actions) {
        BBZFilterAction *filterAction = [[BBZFilterAction alloc] initWithNode:node];
        filterAction.startTime = startTime;
        filterAction.duration = duration;
        [inputTree addAction:filterAction];
    }
    return inputTree;
}

@end
