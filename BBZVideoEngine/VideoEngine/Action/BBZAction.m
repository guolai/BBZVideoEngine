//
//  BBZAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZAction.h"

@interface BBZAction () {
    BOOL _referenceCountingDisabled;
    NSUInteger _referenceCount;
}
@end

@implementation BBZAction

- (instancetype)init {
    if(self = [super init]) {
        _repeatCount = 1;
        _startTime = 0.0;
        _duration = 1.0;
        _referenceCountingDisabled = NO;
        _referenceCount = 0;
    }
    return self;
}


- (void)updateWithTime:(NSUInteger)time {
    
}

- (void)newFrameAtTime:(NSUInteger)time {
    
}

- (void)lock {
    if (_referenceCountingDisabled) {
        return;
    }
    
    _repeatCount++;
}

- (void)unlock {
    if (_referenceCountingDisabled) {
        return;
    }
    
    NSAssert(_repeatCount > 0, @"some thing wrong");
 
    if (_repeatCount < 1) {
        [self destroySomething];
    }
}


- (void)disableReferenceCounting {
    _referenceCountingDisabled = YES;
}

- (void)enableReferenceCounting {
    _referenceCountingDisabled = NO;
}


- (void)destroySomething {
    
}


@end
