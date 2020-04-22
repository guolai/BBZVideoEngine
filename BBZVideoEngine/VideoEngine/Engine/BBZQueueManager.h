//
//  BBZQueueManager.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/22.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBZQueueManager : NSObject

+ (instancetype)shareInstance;
+ (dispatch_queue_t)taskQueue;
+ (dispatch_queue_t)exportQueue;

@end

void BBZRunSynchronouslyOnTaskQueue(void (^block)(void));
void BBZRunAsynchronouslyOnTaskQueue(void (^block)(void));

void BBZRunSynchronouslyOnExportQueue(void (^block)(void));
void BBZRunAsynchronouslyOnExportQueue(void (^block)(void));
