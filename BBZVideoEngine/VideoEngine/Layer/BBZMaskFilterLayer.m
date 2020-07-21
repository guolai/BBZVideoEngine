//
//  BBZMaskFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZMaskFilterLayer.h"
#import "BBZFilterAction.h"
#import "BBZNode+Local.h"


@implementation BBZMaskFilterLayer
//- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
//    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
//    BBZActionBuilderResult *builder = nil;
//    if(self.model.maskImage) {
//        builder = [self buildEffectTimeLine:inputBuilder];
//    }
//    return builder;
//}


//- (BBZActionBuilderResult *)buildEffectTimeLine:(BBZActionBuilderResult *)inputBuilderResult {
//
//    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
//    builder.startTime = 0;
//    builder.groupIndex = 0;
//    NSMutableArray *retArray = [NSMutableArray array];
//    BBZActionTree *maskTree = [BBZActionTree createActionWithBeginTime:0  endTime:inputBuilderResult.startTime];
//
//
//    BBZVistualFilterAction *filterAction = [[BBZVistualFilterAction alloc] initWithNode:node];
//    filterAction.renderSize = self.context.renderSize;
//    filterAction.startTime = 0;
//    filterAction.duration = inputBuilderResult.startTime;
//    [maskTree addAction:filterAction];
//
//    [retArray addObject:maskTree];
//    builder.groupIndex++;
//    builder.assetIndex++;
//    maskTree.groupIndex = builder.groupIndex;
//    builder.groupActions = retArray;
//    return builder;
//}


@end
