//
//  BBZActionMixer.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZActionMixer.h"
#import "BBZFilterAction.h"
#import "BBZActionBuilder.h"

@implementation BBZActionMixer

- (instancetype) init {
    if(self = [super init]) {
        _bOnlyMixActionsInCurrentNodeTree = YES;
    }
    return self;
}

- (NSArray *)combineFiltersFromActionTree:(BBZActionTree *)actionTree {
    NSArray *array = nil;
    if(!actionTree) {
        BBZERROR(@"combineFiltersFromActionTree nil");
        return array;
    }
    
    if(self.bOnlyMixActionsInCurrentNodeTree) {
        array = [self combineFiltersActionNodeTree:actionTree];
    } else {
        array = [self combineFiltersActionFullTrees:actionTree];
    }
    return array;
}

- (NSArray *)combineFiltersActionNodeTree:(BBZActionTree *)actionTree {
    NSArray *array = [BBZActionBuilder connectActionsInTree:actionTree];
    //action 是从根节点到叶子的 所以使用的时候要反过来
    array = [[array reverseObjectEnumerator] allObjects];
    return array;
}

- (NSArray *)combineFiltersActionFullTrees:(BBZActionTree *)actionTree {
    return nil;
}

@end
