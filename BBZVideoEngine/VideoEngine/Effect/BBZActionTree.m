//
//  BBZActionTree.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZActionTree.h"

@interface BBZActionTree ()
@property (nonatomic, strong, readwrite) NSMutableArray<BBZActionTree *> *arrayNodes;
@property (nonatomic, strong, readwrite) NSMutableArray<BBZAction *> *arrayActions;
@property (nonatomic, assign, readwrite) NSUInteger depth;
@end


@implementation BBZActionTree

- (instancetype)init {
    if(self = [super init]) {
        _arrayNodes = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

+ (BBZActionTree *)createActionTreeWithAction:(BBZAction *)action {
    BBZActionTree *actionTree = [[BBZActionTree alloc] init];
    [actionTree addAction:action];
    return actionTree;
}

- (void)addSubTree:(BBZActionTree *)subTree {
    [self.arrayNodes addObject:subTree];
    self.depth = MAX(self.depth, subTree.depth+1);
}

//- (void)removeSubTree:(BBZActionTree *)subTree {
//    [self.arrayNodes removeObject:subTree];
////    self.depth = MAX(self.depth, subTree.depth+1);
//}

- (BOOL)containsChildTree:(BBZActionTree *)subTree {
    BOOL bRet = NO;
    for (BBZActionTree *tmpTree in self.arrayNodes) {
        if(tmpTree == subTree) {
            break;
        } else {
            bRet = [tmpTree containsChildTree:subTree];
        }
    }
    return bRet;
}

- (void)addAction:(BBZAction *)action {
    [self.arrayActions addObject:action];
}

- (NSArray<BBZActionTree *> *)subTrees {
    return [NSArray arrayWithArray:self.arrayNodes];
}

- (NSArray<BBZActionTree *> *)allNodes {
    NSMutableArray *mtblArray = [NSMutableArray array];
    for (BBZActionTree *tmpTree in self.arrayNodes) {
        [mtblArray addObject:tmpTree];
        [mtblArray addObjectsFromArray:[tmpTree allNodes]];
    }
    return mtblArray;
}

- (NSArray<BBZAction *> *)allActions {
    NSMutableArray *mtblArray = [NSMutableArray array];
    [mtblArray addObjectsFromArray:self.actions];
    for (BBZActionTree *tmpTree in self.arrayNodes) {
        [mtblArray addObjectsFromArray:[tmpTree allActions]];
    }
    return mtblArray;
}

- (NSArray<BBZAction *> *)actions {
    return [NSArray arrayWithArray:self.arrayActions];
}

- (void)remoeAllSubTrees {
    [self.arrayNodes removeAllObjects];
}

- (BBZActionTree *)mergeWithOtherTree:(BBZActionTree *)otherTree {
    BBZActionTree *parentTree = [[BBZActionTree alloc] init];
    [parentTree addSubTree:self];
    [parentTree addSubTree:otherTree];
    return nil;
}

- (NSString *)debugDescription {
    NSMutableString *mtblString = [NSMutableString  string];
    [mtblString appendString:[NSString stringWithFormat:@"Action:%@\n", self.arrayActions]];
    [mtblString appendString:@"subNodes:\n"];
    for (BBZActionTree *tmpTree in self.arrayNodes) {
        [mtblString appendString:[tmpTree debugDescription]];
    }
    return mtblString;
}

@end
