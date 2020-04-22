//
//  BBZTaskFlow.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTaskFlow.h"
#import "BBZQueueManager.h"

@interface BBZTaskFlow ()<BBZTaskDelegate>
@property (nonatomic, assign) NSInteger nextTaskIndex;
@property (nonatomic, strong) BBZTask *runningTask;
@property (nonatomic, assign) float totalProgressOfCompletedTasks;
@end


@implementation BBZTaskFlow
@synthesize tasks = _tasks;

- (instancetype)initWithTasks:(NSArray<BBZTask*> *)tasks {
    if(self = [super init]) {
        _tasks = [NSMutableArray array];
        _nextTaskIndex = 0;
        _runningTask = 0;
        _tasks = tasks;
    }
    return self;
}


+ (instancetype)taskQueueWithTasks:(NSArray<BBZTask*> *)tasks {
    BBZTaskFlow *taskQueue = [[BBZTaskFlow alloc] init];
    return taskQueue;
}


- (void)completeWithError:(NSError *)error {
    self.state = BBZTaskStateFinish;
    self.progress = 1.0;
    if(self.completeBlock) {
        self.completeBlock(self, error);
    }
}

- (void)updateProgress:(float)progress {
    float currentProgress = self.totalProgressOfCompletedTasks;
    currentProgress += self.runningTask.progress * self.runningTask.weight;

    //NSLog(@"currentProgress = %.3f", currentProgress);
    self.progress = MIN(1.0, currentProgress);
    
    if (self.updateProgressBlock) {
        self.updateProgressBlock(self, self.progress);
    }
}

- (BOOL)start {
    __block BOOL bRet = YES;
    if(self.tasks.count == 0) {
        self.state = BBZTaskStateIdel;
        bRet = NO;
        return bRet;
    }
    BBZRunSynchronouslyOnTaskQueue(^{
        if(self.state == BBZTaskStateFinish ||
           self.state == BBZTaskStateRunning) {
            BBZINFO(@"%@ is running ", self);
        }
        if(self.state == BBZTaskStateIdel) {
            [self analyzeProgressWeightsForAllTasks];
        }
        [self attamptToRunTasks];
        self.state = BBZTaskStateRunning;
    });
    return bRet;
}

- (BOOL)pause {
    BOOL bRet = YES;
    if(self.state == BBZTaskStateIdel ||
       self.state == BBZTaskStateFinish) {
        bRet = NO;
        return bRet;
    }
    BBZRunSynchronouslyOnTaskQueue(^{
        [self.runningTask pause];
    });

    self.state = BBZTaskStatePause;
    return bRet;
}

- (BOOL)cancel {
    BOOL bRet = YES;
    if(self.state == BBZTaskStateIdel ||
       self.state == BBZTaskStateFinish) {
        bRet = NO;
        return bRet;
    }
    BBZRunSynchronouslyOnTaskQueue(^{
        [self.runningTask cancel];
    });
    self.state = BBZTaskStateCancel;
    return bRet;
}

- (void)reset {
    self.nextTaskIndex = 0;
    self.runningTask = nil;
    self.totalProgressOfCompletedTasks = 0;
    self.progress = 0.0;
    self.state = BBZTaskStateIdel;
    for (BBZTask *task in self.tasks) {
        task.state = BBZTaskStateIdel;
        task.progress = 0;
    }
}

#pragma mark - TaskDelegate
- (void)task:(BBZTask *)task didCompleteWithError:(NSError *)error {

    if(self.state == BBZTaskStateCancel) {
        return;
    }
    if (self.taskCompleteBlock) {
        self.taskCompleteBlock(self, task, error);
    }
    
    if (error != nil) {
        [self completeWithError:error];
        return;
    }

    task.progress = 1.0;
    self.totalProgressOfCompletedTasks += task.weight;
    
    BBZINFO(@"taskDidComplete: %@, error:%@", task, error);
    
    [self updateProgress:self.progress];
    [self attamptToRunTasks];
}

- (void)task:(BBZTask *)task didUpdateProgress:(float)progress {
    if(self.state == BBZTaskStateCancel ||
       self.state == BBZTaskStatePause) {
        return;
    }
    [self updateProgress:self.progress];
}

#pragma mark - Private

- (void)analyzeProgressWeightsForAllTasks {
    float totalCost = 0;
    
    for (BBZTask *task in self.tasks) {
        [task setValue:self forKey:@"scheduler"];
        totalCost += task.cost;
    }
    
    if (totalCost > 0) {
        for (BBZTask *task in self.tasks) {
            task.weight = task.cost / totalCost;
        }
    } else {
        float weight = 1.0 / self.tasks.count;
        for (BBZTask *task in self.tasks) {
            task.weight = weight;
        }
    }
}

- (void)attamptToRunTasks {
    if(self.runningTask.state == BBZTaskStateRunning) {
        NSAssert(false, @"state error");
        BBZERROR(@"error");
        return;
    }
    if(self.runningTask.state != BBZTaskStateFinish) {
        [self.runningTask start];
        return;
    }

    for (NSInteger i = self.nextTaskIndex; i < self.tasks.count; ++i) {
        self.nextTaskIndex = i + 1;
        BBZTask *task = [self.tasks objectAtIndex:i];
        if(task.state != BBZTaskStateFinish) {
            self.runningTask = task;
            [task start];
            break;
        }
    }
    if(!self.runningTask) {
        BBZRunAsynchronouslyOnTaskQueue(^{
            [self completeWithError:nil];
        });
    }
}

@end
