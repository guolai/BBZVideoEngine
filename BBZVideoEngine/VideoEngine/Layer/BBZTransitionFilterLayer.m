//
//  BBZTransitionFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/5/5.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZTransitionFilterLayer.h"
#import "BBZVideoSourceAction.h"
#import "BBZImageSourceAction.h"
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
        NSUInteger transionDuration = transition.duration * BBZVideoDurationScale;
        builder.startTime -= transionDuration;
        NSAssert(builder.startTime > 0, @"transionStartTime error");
        NSAssert((spliceTree.beginTime - transionDuration > 0), @"transionStartTime error");
        [spliceTree updateOffsetTime:transionDuration];
        
        BBZActionTree *transitionTree = [self actionTreeWithTransitionNode:transition.transitionNode duration:transionDuration startTime:builder.startTime];
        
        BBZInputNode *input1 = [transition.inputNodes objectAtIndex:0];
        BBZActionTree *inputActionTree1 = [self actionTreeWithInputNode:input1 duration:transionDuration startTime:builder.startTime];
        if(!inputActionTree1) {
            [transitionTree addSubTree:beforeTree];
        } else {
            [inputActionTree1 addSubTree:beforeTree];
            [transitionTree addSubTree:inputActionTree1];
        }
        
        BBZInputNode *input2 = [transition.inputNodes objectAtIndex:0];
        BBZActionTree *inputActionTree2= [self actionTreeWithInputNode:input2 duration:transionDuration startTime:builder.startTime];
        if(!inputActionTree2) {
            [transitionTree addSubTree:spliceTree];
        } else {
            [inputActionTree2 addSubTree:spliceTree];
            [transitionTree addSubTree:inputActionTree2];
        }
        
        [retArray addObject:transitionTree];
        beforeTree = spliceTree;
        builder.startTime += (beforeTree.endTime - beforeTree.beginTime);
    }
    
    builder.groupActions = retArray;
    return builder;
}




- (BBZActionTree *)actionTreeWithInputNode:(BBZInputNode *)inputNode
                                  duration:(NSUInteger)duration
                                 startTime:(NSUInteger)startTime{
    BBZActionTree *inputTree = [BBZActionTree createActionWithBeginTime:startTime endTime:startTime+duration];
    for (BBZNode *node in inputNode.actions) {
        BBZFilterAction *filterAction = [[BBZFilterAction alloc] initWithNode:node];
        filterAction.startTime = startTime;
        filterAction.duration = duration;
        [inputTree addAction:filterAction];
    }
    if(inputTree.actions.count == 0) {
        inputTree = nil;
    }
    return inputTree;
}


- (BBZActionTree *)actionTreeWithTransitionNode:(BBZTransitionNode *)transitionNode
                                       duration:(NSUInteger)duration
                                      startTime:(NSUInteger)startTime{
    BBZActionTree *transitionTree = [BBZActionTree createActionWithBeginTime:startTime endTime:startTime+duration];
    for (BBZNode *node in transitionNode.actions) {
        BBZFilterAction *filterAction = [[BBZFilterAction alloc] initWithNode:node];
        filterAction.startTime = startTime;
        filterAction.duration = duration;
        [transitionTree addAction:filterAction];
    }
    NSAssert(transitionTree.actions.count > 0, @"transitionTree action cannot be nil");
    return transitionTree;
}

@end
