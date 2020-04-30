//
//  BBZActionTree.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZActionTree.h"

@interface BBZActionTree ()
@property (nonatomic, strong, readonly) NSArray *subActions;
@end


@implementation BBZActionTree

- (void)addSubTree:(BBZActionTree *)subTree {
    
}

- (void)removeSubTree:(BBZActionTree *)subTree {
    
}

- (BOOL)containsChildTree:(BBZActionTree *)subTree {
    return YES;
}

- (void)remoeAllSubTrees {
    
}

- (BBZActionTree *)mergeWithTree:(BBZActionTree *)otherTree {
    return nil;
}
@end
