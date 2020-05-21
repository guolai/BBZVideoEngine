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
@synthesize node = _node;

- (instancetype)init {
    if(self = [super init]) {
        _repeatCount = 1;
        _startTime = 0;
        _duration = 0;
        _referenceCountingDisabled = NO;
        _referenceCount = 0;
    }
    return self;
}

- (instancetype)initWithNode:(BBZNode *)node {
    if([self init]) {
        _node = node;
    }
    return self;
}


- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    
}

- (void)lock {
    if (_referenceCountingDisabled) {
        return;
    }
    
    _referenceCount++;
}

- (void)unlock {
    if (_referenceCountingDisabled) {
        return;
    }
    
    NSAssert(_referenceCount > 0, @"some thing wrong");
    _referenceCount++;
    if (_referenceCount < 1) {
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

- (NSUInteger)endTime {
    return self.startTime + self.duration * self.repeatCount;
}

@end
