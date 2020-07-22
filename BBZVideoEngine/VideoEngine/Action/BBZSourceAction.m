//
//  BBZSourceAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZSourceAction.h"

@implementation BBZInputSourceParam
@end


@implementation BBZSourceAction
@synthesize asset = _asset;



- (instancetype)init {
    if(self = [super init]) {
        _scale = 1.0;
    }
    return self;
}

- (BBZInputSourceParam *)inputSourceAtTime:(CMTime)time {
    return nil;
}

- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    
}

- (void)removeConnects {
    
}

- (id)filter {
    return nil;
}

- (void)connectToAction:(id<BBZActionChainProtocol>)toAction {
    
}


@end
