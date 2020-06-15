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
        _order = 88888;
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

//- (void)upateOffsetTime:(NSInteger)offset {
//    double dOffset = offset/(BBZVideoDurationScale * 1.0);
//    self.node.offset = dOffset;
//}

- (NSTimeInterval)relativeTimeFrom:(CMTime)time {
    NSTimeInterval tmpTime = CMTimeGetSeconds(time);
    tmpTime = tmpTime - self.startTime/(BBZVideoDurationScale * 1.0);
    return tmpTime;
    
}

- (NSInteger)order {
    if(_order == 88888) {
        if(self.node) {
            return self.node.order;
        } else {
            return 0;
        }
    }
    return _order;
}

- (NSUInteger)endTime {
    return self.startTime + self.duration * self.repeatCount;
}

- (CMTime)startCMTime {
    return CMTimeMake(self.startTime * BBZVideoDurationScale, BBZVideoDurationScale);
}

- (CMTime)durationCMTime {
    return CMTimeMake((self.endTime - self.startTime) * BBZVideoDurationScale, BBZVideoDurationScale);
}

- (NSString *)debugDescription {
    NSString *retString = [NSString stringWithFormat:@"starttime:%lu, endTime:%lu, duration:%lu, repeat:%ld, refcount:%ld,disableRef:%d", self.startTime, self.endTime, self.duration, self.repeatCount, _referenceCount, _referenceCountingDisabled];
    return retString;
}

- (void)removeConnects {
    
}

@end
