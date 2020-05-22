//
//  BBZEffetFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZEffetFilterLayer.h"
#import "BBZFilterAction.h"

@implementation BBZEffetFilterLayer

- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    BBZActionBuilderResult *builder = nil;
    if(self.model.filterModel.filterGroups.count > 0) {
        builder = [self buildEffectTimeLine:inputBuilder];
    }
    return builder;
}


- (BBZActionBuilderResult *)buildEffectTimeLine:(BBZActionBuilderResult *)inputBuilderResult {
    
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    for (BBZFilterNode *filterNode in self.model.filterModel.filterGroups) {
        NSUInteger startTime = filterNode.begin * BBZVideoDurationScale;
        if(filterNode.bPlayFromEnd) {
            startTime = MAX(inputBuilderResult.startTime - filterNode.duration, 0);
        }
        BBZActionTree *effectTree = [self actionTreeWithFilterNode:filterNode duration:filterNode.duration startTime:startTime];
        if(effectTree) {
            [retArray addObject:effectTree];
            builder.groupIndex++;
            builder.assetIndex++;
        }
    }
    
    builder.groupActions = retArray;
    return builder;
 
}

- (BBZActionTree *)actionTreeWithFilterNode:(BBZFilterNode *)filterNode
                                  duration:(NSUInteger)duration
                                 startTime:(NSUInteger)startTime{
    BBZActionTree *effectTree = [BBZActionTree createActionWithBeginTime:startTime endTime:startTime+duration];
    for (BBZNode *node in filterNode.actions) {
        BBZFilterAction *filterAction = [[BBZFilterAction alloc] initWithNode:node];
        filterAction.startTime = startTime + node.begin * BBZVideoDurationScale;
        filterAction.duration = MIN(duration, (node.end - node.begin) * node.repeat * BBZVideoDurationScale);
        [effectTree addAction:filterAction];
    }
    if(effectTree.actions.count == 0) {
        effectTree = nil;
    }
    return effectTree;
}


@end
