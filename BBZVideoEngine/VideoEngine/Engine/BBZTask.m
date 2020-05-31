//
//  BBZTask.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTask.h"

@interface BBZTask ()
@property (nonatomic, weak) id<BBZTaskDelegate> scheduler;
@end

@implementation BBZTask

- (instancetype)init {
    if(self = [super init]) {
        _cost = 0.0;
        _progress = 0.0;
        _weight = 0.0;
        _state = BBZTaskStateIdel;
    }
    return self;
}

- (BOOL)start {
    self.state = BBZTaskStateRunning;
    return YES;
}

- (BOOL)pause {
    self.state = BBZTaskStatePause;
    return YES;
}

- (BOOL)cancel {
    self.state = BBZTaskStateCancel;
    return YES;
}

- (void)completeWithError:(NSError *)error {
    self.state = BBZTaskStateFinish;
    if (self.scheduler) {
        [self.scheduler task:self didCompleteWithError:error];
    }
}

- (void)updateProgress:(float)progress {
    self.progress = progress;
    if (self.scheduler) {
        [self.scheduler task:self didUpdateProgress:progress];
    }
}

@end
