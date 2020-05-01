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

+ (BBZActionTree *)createActionTreeWithAction:(BBZAction *)action;

- (void)addSubTree:(BBZActionTree *)subTree;
//- (void)removeSubTree:(BBZActionTree *)subTree;
- (BOOL)containsChildTree:(BBZActionTree *)subTree;

- (void)addAction:(BBZAction *)action;

- (void)remoeAllSubTrees;

- (BBZActionTree *)mergeWithOtherTree:(BBZActionTree *)otherTree;


@end


