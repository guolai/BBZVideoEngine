//
//  BBZFilterMixer.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterMixer.h"

@interface BBZFilterMixer ()

@end


@implementation BBZFilterMixer


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
    
    return nil;
}

- (NSArray *)combineFiltersActionFullTrees:(BBZActionTree *)actionTree {
    
    return nil;
}


@end
