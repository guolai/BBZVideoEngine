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

+ (BBZActionTree *)createActionWithBeginTime:(NSUInteger)beginTime endTime:(NSUInteger)endTime {
    BBZActionTree *actionTree = [[BBZActionTree alloc] init];
    actionTree.beginTime = beginTime;
    actionTree.endTime = endTime;
    NSAssert(beginTime < endTime, @"segment error");
    return actionTree;
}

+ (BBZActionTree *)createActionTreeWithAction:(BBZAction *)action {
    BBZActionTree *actionTree = [BBZActionTree createActionWithBeginTime:action.startTime endTime:action.endTime];
    [actionTree addAction:action];
    return actionTree;
}

- (void)addSubTree:(BBZActionTree *)subTree {
    if(subTree.beginTime > self.beginTime || subTree.endTime < self.endTime) {
        BBZERROR(@"segment error %u, %u, %u, %u", subTree.beginTime, subTree.endTime, self.beginTime, self.endTime);
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
    if(action.startTime < self.beginTime || action.endTime > self.endTime) {
        BBZERROR(@"segment error %u, %u, %u, %u", action.startTime, action.endTime, self.beginTime, self.endTime);
        NSAssert(false, @"segment error");
    }
 
    BOOL bAdd = NO;
    for (int i = 0; i < self.arrayActions.count; i++) {
        BBZAction *tmpaction = [self.arrayActions objectAtIndex:i];
        if(tmpaction.startTime > action.startTime) {
            [self.arrayActions insertObject:action atIndex:i];
            bAdd = YES;
            break;
        }
    }
    if(!bAdd) {
        [self.arrayActions addObject:action];
    }
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


//- (BBZActionTree *)mergeWithOtherTree:(BBZActionTree *)otherTree {
//    BBZActionTree *parentTree = [[BBZActionTree alloc] init];
//    [parentTree addSubTree:self];
//    [parentTree addSubTree:otherTree];
//    return parentTree;
//}


- (BBZActionTree *)subTreeFromTime:(NSUInteger)startTime endTime:(NSUInteger)endTime {
    BBZActionTree *subTree = [BBZActionTree createActionWithBeginTime:startTime endTime:endTime];
    for (BBZAction *action in self.actions) {
        if(action.startTime <= startTime && action.endTime >= endTime) {
            [subTree addAction:action];
        }
    }
    if(subTree.actions.count == 0) {
        subTree = nil;
    }
    return subTree;
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

- (BOOL)isValidTree {
    BOOL bValid = NO;
    CMTimeRange wholeTimeRange = CMTimeRangeMake(self.startCMTime, self.durationCMTime);
    if(!CMTIMERANGE_IS_VALID(wholeTimeRange)) {
        NSAssert(bValid, @"isValidTree");
        BBZERROR(@"isValidTree no %@", self.debugDescription);
        return bValid;
    }
    CGFloat duraton = 0.0;
    CMTimeRange lastActionTimeRange = kCMTimeRangeZero;
    for (int i = 0; i < self.actions.count; i++) {
        BBZAction *tmpAction = [self.actions objectAtIndex:i];
        duraton += CMTimeGetSeconds(tmpAction.durationCMTime);
        CMTimeRange actionTimeRange = CMTimeRangeMake(tmpAction.startCMTime, tmpAction.durationCMTime);
        CMTimeRange intersectionRange = CMTimeRangeGetIntersection(lastActionTimeRange, actionTimeRange);
        if(!CMTIMERANGE_IS_VALID(intersectionRange)) {
            NSAssert(bValid, @"isValidTree");
            BBZERROR(@"isValidTree no %@", self.debugDescription);
            return bValid;
        }
        duraton -= CMTimeGetSeconds(intersectionRange.duration);
        if(i != 0) {
            if(CMTimeGetSeconds(actionTimeRange.start) > CMTimeGetSeconds(lastActionTimeRange.start) ||
               (fabs(CMTimeGetSeconds(actionTimeRange.start) - CMTimeGetSeconds(lastActionTimeRange.start))< 0.001 &&
                CMTimeGetSeconds(actionTimeRange.duration) > CMTimeGetSeconds(lastActionTimeRange.duration))) {
                   lastActionTimeRange = actionTimeRange;
               }
        } else {
            lastActionTimeRange = actionTimeRange;
        }
    }
    if(fabs(duraton - (self.endTime - self.beginTime)) < 0.001) {
        bValid = YES;
    }
    for (BBZActionTree *tree in self.subTrees) {
        if(![tree isValidTree]) {
            bValid = NO;
            break;
        }
    }
    NSAssert(bValid, @"isValidTree");
    BBZERROR(@"isValidTree no %@", self.debugDescription);
    return bValid;
}

- (BOOL)shouldSplit {
    BOOL bSplit = NO;
    for (BBZAction *action in self.actions) {
        if(action.startTime > self.beginTime && action.endTime < self.endTime) {
            bSplit = YES;
            break;
        }
    }
    if(!bSplit) {
        for (BBZActionTree *tree in self.subTrees) {
            if(![tree shouldSplit]) {
                bSplit = NO;
                break;
            }
        }
    }
    return bSplit;
}

- (CMTime)startCMTime {
    return CMTimeMake(self.beginTime * BBZVideoDurationScale, BBZVideoDurationScale);
}

- (CMTime)durationCMTime {
    return CMTimeMake((self.endTime - self.beginTime) * BBZVideoDurationScale, BBZVideoDurationScale);
}

@end
