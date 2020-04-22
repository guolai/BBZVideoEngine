//
//  BBZTaskFlow.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZTask.h"

NS_ASSUME_NONNULL_BEGIN



@class BBZTaskFlow;
typedef void (^BBZTaskFlowCompleteBlock)(BBZTaskFlow *taskFlow, BBZTask *task, NSError *error);

@interface BBZTaskFlow : BBZTask
@property (nonatomic, strong, readonly) NSArray<BBZTask *> *tasks;


@property (nonatomic, copy) BBZTaskCompleteBlock completeBlock;
@property (nonatomic, copy) BBZTaskUpdateProgressBlock updateProgressBlock;
@property (nonatomic, copy) BBZTaskFlowCompleteBlock taskCompleteBlock;

+ (instancetype)taskQueueWithTasks:(NSArray<BBZTask*> *)tasks;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
