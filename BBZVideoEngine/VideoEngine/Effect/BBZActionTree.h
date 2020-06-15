//
//  BBZActionTree.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZAction.h"


@interface BBZActionTree : NSObject
@property (nonatomic, strong, readonly) NSArray<BBZActionTree *> *subTrees;
@property (nonatomic, strong, readonly) NSArray<BBZActionTree *> *allNodes;
@property (nonatomic, strong, readonly) NSArray<BBZAction *> *allActions;
@property (nonatomic, strong, readonly) NSArray<BBZAction *> *actions;
@property (nonatomic, assign, readonly) NSUInteger depth;

@property (nonatomic, assign, readonly) NSUInteger beginTime;
@property (nonatomic, assign, readonly) NSUInteger endTime;
@property (nonatomic, assign, readonly) NSInteger offset;

@property (nonatomic, assign) NSInteger groupIndex;

@property (nonatomic, assign, readonly) CMTime startCMTime;
@property (nonatomic, assign, readonly) CMTime durationCMTime;

+ (BBZActionTree *)createActionWithBeginTime:(NSUInteger)beginTime endTime:(NSUInteger)endTime;
+ (BBZActionTree *)createActionTreeWithAction:(BBZAction *)action;

- (void)addSubTree:(BBZActionTree *)subTree;
//- (void)removeSubTree:(BBZActionTree *)subTree;
- (BOOL)containsChildTree:(BBZActionTree *)subTree;
- (void)addAction:(BBZAction *)action;
- (void)remoeAllSubTrees;
- (BBZActionTree *)subTreeAtIndex:(NSUInteger)index;
- (BOOL)addSubTreeToLeftTerminal:(BBZActionTree *)subTree;//如果当前树的左子树有分叉则添加失败，需要跳过
- (BOOL)addSubTreeToRightTerminal:(BBZActionTree *)subTree;//如果当前树的右子有分叉则添加失败，需要跳过

- (void)updateOffsetTime:(NSInteger)time;
- (NSUInteger)duration;

//- (BBZActionTree *)mergeWithOtherTree:(BBZActionTree *)otherTree;

- (BBZActionTree *)subTreeFromTime:(NSUInteger)startTime endTime:(NSUInteger)endTime;

- (BOOL)isValidTree;
- (BOOL)shouldSplit;
- (BOOL)isSingleChain;//单链判断


@end


