//
//  BBZQueueManager.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/22.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZQueueManager.h"

static void *bbzvideoEngineTaskKey;
static void *bbzvideoEngineExportKey;

@interface BBZQueueManager ()
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, strong) dispatch_queue_t exportQueue;
@end

@implementation BBZQueueManager

- (instancetype)init {
    if(self = [super init]) {
        _taskQueue = dispatch_queue_create("com.bob.bbzvideoEngine.taskqueue", DISPATCH_QUEUE_SERIAL);
        bbzvideoEngineTaskKey = &bbzvideoEngineTaskKey;
        dispatch_queue_set_specific(_taskQueue, bbzvideoEngineTaskKey, (__bridge void *)self, NULL);
        _exportQueue = dispatch_queue_create("com.bob.bbzvideoEngine.exportqueue", DISPATCH_QUEUE_SERIAL);
        bbzvideoEngineExportKey = &bbzvideoEngineExportKey;
        dispatch_queue_set_specific(_exportQueue, bbzvideoEngineExportKey, (__bridge void *)self, NULL);
    }
    return self;
}

+ (instancetype)shareInstance {
    static BBZQueueManager *queueManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queueManager = [[BBZQueueManager alloc] init];
    });
    return queueManager;
}


+ (dispatch_queue_t)taskQueue {
    return [BBZQueueManager shareInstance].taskQueue;
}

+ (dispatch_queue_t)exportQueue {
    return [BBZQueueManager shareInstance].exportQueue;
}

#pragma mark - Private

+ (void *)taskKey {
    return bbzvideoEngineTaskKey;
}

+ (void *)exportKey {
    return bbzvideoEngineExportKey;
}

@end


void BBZRunSynchronouslyOnTaskQueue(void (^block)(void))
{
    dispatch_queue_t queue = [BBZQueueManager taskQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == queue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([BBZQueueManager taskKey]))
#endif
        {
            block();
        }else
        {
            dispatch_sync(queue, block);
        }
}

void BBZRunAsynchronouslyOnTaskQueue(void (^block)(void))
{
    dispatch_queue_t queue = [BBZQueueManager taskQueue];
    
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == queue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([BBZQueueManager taskKey]))
#endif
        {
            block();
        }else
        {
            dispatch_async(queue, block);
        }
}

void BBZRunSynchronouslyOnExportQueue(void (^block)(void))
{
    dispatch_queue_t queue = [BBZQueueManager exportQueue];
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == queue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([BBZQueueManager exportKey]))
#endif
        {
            block();
        }else
        {
            dispatch_sync(queue, block);
        }
}

void BBZRunAsynchronouslyOnExportQueue(void (^block)(void))
{
    dispatch_queue_t queue = [BBZQueueManager exportQueue];
    
#if !OS_OBJECT_USE_OBJC
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == queue)
#pragma clang diagnostic pop
#else
        if (dispatch_get_specific([BBZQueueManager exportKey]))
#endif
        {
            block();
        }else
        {
            dispatch_async(queue, block);
        }
}


