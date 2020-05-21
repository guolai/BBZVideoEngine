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
@property (nonatomic, assign, readwrite) NSUInteger beginTime;
@property (nonatomic, assign, readwrite) NSUInteger endTime;
@property (nonatomic, assign, readwrite) NSUInteger offset;
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
    actionTree.beginTime = action.startTime;
    actionTree.endTime = action.startTime+action.duration;
    [actionTree addAction:action];
    return actionTree;
}

- (void)addSubTree:(BBZActionTree *)subTree {
    if(subTree.beginTime > self.beginTime || subTree.endTime < self.endTime) {
        BBZERROR(@"segment error %ld, %ld, %ld, %ld", subTree.beginTime, subTree.endTime, self.beginTime, self.endTime);
        NSAssert(false, @"segment error");
    }
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
    if(self.beginTime == self.endTime && self.beginTime == 0) {
        self.beginTime = action.startTime;
        self.endTime = action.endTime;
    }
    if(action.startTime > self.beginTime || action.endTime < self.endTime) {
        BBZERROR(@"segment error %ld, %ld, %ld, %ld", action.startTime, action.endTime, self.beginTime, self.endTime);
        NSAssert(false, @"segment error");
    }
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


- (BBZActionTree *)subTreeFromTime:(NSUInteger)startTime endTime:(NSUInteger)endTime {
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

- (void)updateOffsetTime:(NSUInteger)time {
    if(self.offset == time) {
        return;
    }
    self.offset = time;
    for (BBZAction *action in self.arrayActions) {
        action.startTime = self.beginTime;
    }
    for (BBZActionTree *tree in self.arrayNodes) {
        [tree updateOffsetTime:time];
    }
}

- (NSUInteger)beginTime {
    return _beginTime + self.offset;
}

- (NSUInteger)endTime {
    return _endTime + self.offset;
}

- (NSUInteger)duration {
    return self.endTime - self.beginTime;
}

@end
