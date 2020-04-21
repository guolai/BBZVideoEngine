//
//  BBZTaskQueue.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTaskQueue.h"

@interface BBZTaskQueue ()<BBZTaskDelegate>
@property (nonatomic, strong) NSMutableArray *allTasks;
@property (nonatomic, assign) NSInteger nextTaskIndex;
@property (nonatomic, strong) BBZTask *runningTask;
@property (nonatomic, assign) float totalProgressOfCompletedTasks;
@end


@implementation BBZTaskQueue

- (instancetype)init {
    if(self = [super init]) {
        _allTasks = [NSMutableArray array];
        _nextTaskIndex = 0;
        _runningTask = 0;
    }
    return self;
}


+ (instancetype)taskQueueWithTasks:(NSArray<BBZTask*> *)tasks {
    BBZTaskQueue *taskQueue = [[BBZTaskQueue alloc] init];
    return nil;
}

#pragma mark - TaskDelegate
- (void)task:(BBZTask *)task didCompleteWithError:(NSError *)error {
    
}

- (void)task:(BBZTask *)task didUpdateProgress:(float)progress {
    
}

@end
