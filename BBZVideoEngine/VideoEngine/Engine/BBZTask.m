//
//  BBZTask.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTask.h"

@implementation BBZTask

- (void)start {
    _state = BBZTaskStateRunning;
}

- (void)pause {
    _state = BBZTaskStatePause;
}

- (void)cancel {
    _state = BBZTaskStateCancel;
}

@end
