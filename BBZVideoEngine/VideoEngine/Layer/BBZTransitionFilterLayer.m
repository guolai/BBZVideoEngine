//
//  BBZTransitionFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/5/5.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZTransitionFilterLayer.h"
#import "BBZVideoAction.h"
#import "BBZImageAction.h"
#import "BBZInputFilterAction.h"

@implementation BBZTransitionFilterLayer

- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    BBZActionBuilderResult *builder = nil;
    if(self.model.transitonModel.transitionGroups.count == 0) {
        builder = inputBuilder;
    } else {
        builder = [self buildTranstionTimeLine:inputBuilder];
    }
    return builder;
}


- (BBZActionBuilderResult *)buildTranstionTimeLine:(BBZActionBuilderResult *)inputBuilderResult {
//    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
//    builder.startTime = 0;
//    builder.groupIndex = 0;
//    NSMutableArray *retArray = [NSMutableArray array];
//    NSInteger transionIndex = 0;
//    BBZActionTree *beforeTree = nil;
//    for (BBZTransitionGroupNode *transition in self.model.transitonModel.transitionGroups) {
//        BBZActionTree *transtionTree = [self actionTreeWithTransitionNode:transition.transitionNode duration:transition.duration startTime:builder.startTime];
//
//        BBZInputNode *leftInputNode = [transition.inputNodes objectAtIndex:0];
//        BBZActionTree *leftInputTree = [self actionTreeWithInputNode:leftInputNode duration:0 startTime:0];
//    }
//
    
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    NSInteger transionIndex = 0;
    BBZActionTree *beforeTree = nil;
    for (BBZActionTree *spliceTree in inputBuilderResult.groupActions) {
        if(!beforeTree) {
            beforeTree = spliceTree;
            builder.startTime = beforeTree.endTime;
            continue;
        }
        if(transionIndex >= self.model.transitonModel.transitionGroups.count) {
            transionIndex = 0;
        }
    
        BBZTransitionGroupNode *transition = [self.model.transitonModel.transitionGroups objectAtIndex:transionIndex];
        NSUInteger transionDuration = transition.duration;
        builder.startTime -= transionDuration;
        NSAssert(builder.startTime > 0, @"transionStartTime error");
        NSAssert((spliceTree.beginTime - transionDuration > 0), @"transionStartTime error");    
    }
    
    builder.groupActions = retArray;
    return builder;
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


- (BBZActionTree *)actionTreeWithTransitionNode:(BBZTransitionNode *)transitionNode
                                       duration:(NSUInteger)duration
                                      startTime:(NSUInteger)startTime{
    BBZActionTree *spliceTree = [[BBZActionTree alloc] init];
    for (BBZNode *node in transitionNode.actions) {
        BBZFilterAction *filterAction = [[BBZFilterAction alloc] initWithNode:node];
        filterAction.startTime = startTime;
        filterAction.duration = duration;
        [spliceTree addAction:filterAction];
    }
    
    return spliceTree;
}

@end
