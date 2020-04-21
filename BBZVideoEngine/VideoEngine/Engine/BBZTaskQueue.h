//
//  BBZTaskQueue.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZTask.h"

NS_ASSUME_NONNULL_BEGIN



@class BBZTaskQueue;
typedef void (^BBZTaskQueueCompleteBlock)(BBZTaskQueue *taskFlow, BBZTask *task, NSError *error);

@interface BBZTaskQueue : BBZTask
@property (nonatomic, strong, readonly) NSArray<BBZTask *> *tasks;


@property (nonatomic, copy) BBZTaskCompleteBlock completeBlock;
@property (nonatomic, copy) BBZTaskUpdateProgressBlock updateProgressBlock;
@property (nonatomic, copy) BBZTaskQueueCompleteBlock taskCompleteBlock;

+ (instancetype)taskQueueWithTasks:(NSArray<BBZTask*> *)tasks;
@end

NS_ASSUME_NONNULL_END
