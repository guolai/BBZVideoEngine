//
//  BBZTaskQueue.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTaskQueue.h"

@interface BBZTaskQueue ()<BBZTaskDelegate>
@property (nonatomic, strong, readwrite) NSMutableArray *allTasks;
@property (nonatomic, assign) NSInteger nextTaskIndex;
@property (nonatomic, strong) BBZTask *runningTask;
@property (nonatomic, assign) float totalProgressOfCompletedTasks;
@end


@implementation BBZTaskQueue

- (instancetype)initWithTasks:(NSArray<BBZTask*> *)tasks {
    if(self = [super init]) {
        _allTasks = [NSMutableArray array];
        _nextTaskIndex = 0;
        _runningTask = 0;
        _tasks = tasks;
    }
    return self;
}


+ (instancetype)taskQueueWithTasks:(NSArray<BBZTask*> *)tasks {
    BBZTaskQueue *taskQueue = [[BBZTaskQueue alloc] init];
    return taskQueue;
}


- (void)completeWithError:(NSError *)error {

}

- (void)updateProgress:(float)progress {
 
}

- (BOOL)start {
    BOOL bRet = NO;
    if(self.state == BBZTaskStateFinish ||
       self.state == BBZTaskStateRunning) {
        bRet = YES;
    }
    if(!bRet) {
        
    }
    self.state = BBZTaskStateRunning;
    return bRet;
}

- (BOOL)pause {
    BOOL bRet = NO;
    if(self.state == BBZTaskStateFinish ||
       self.state == BBZTaskStateRunning) {
        bRet = YES;
    }
    if(!bRet) {
        
    }
    self.state = BBZTaskStateRunning;
    return bRet;
}

- (BOOL)cancel {
    BOOL bRet = NO;
    if(self.state == BBZTaskStateFinish ||
       self.state == BBZTaskStateRunning) {
        bRet = YES;
    }
    if(!bRet) {
        
    }
    self.state = BBZTaskStateRunning;
    return bRet;
}


#pragma mark - TaskDelegate
- (void)task:(BBZTask *)task didCompleteWithError:(NSError *)error {
    
}

- (void)task:(BBZTask *)task didUpdateProgress:(float)progress {
    
}

#pragma mark - Private
- (void)reset {
    _nextTaskIndex = 0;
    _runningTask = nil;
    _totalProgressOfCompletedTasks = 0;
}

- (void)attamptToRunTasks {
    if(self.runningTask.state == BBZTaskStateRunning) {
        NSAssert(false, @"state error");
        BBZINFO(@"error");
        return;
    }
    if(self.runningTask.state != BBZTaskStateFinish) {
        [self.runningTask start];
        return;
    }
    

//
//    if ((_state == MVTaskFlowStateRunning) && [self isAllTasksCompleted])
//    {
//        [self completeWithError:nil];
//    }
}

@end
