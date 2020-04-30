//
//  BBZActionTree.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBZActionTree : NSObject
@property (nonatomic, strong, readonly) NSArray *subActions;

- (void)addSubTree:(BBZActionTree *)subTree;
- (void)removeSubTree:(BBZActionTree *)subTree;
- (BOOL)containsChildTree:(BBZActionTree *)subTree;

- (void)remoeAllSubTrees;

- (BBZActionTree *)mergeWithTree:(BBZActionTree *)otherTree;

@end


