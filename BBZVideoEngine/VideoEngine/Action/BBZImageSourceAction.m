//
//  BBZImageSourceAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZImageSourceAction.h"
#import "BBZImageAsset.h"
#import "GPUImageFramebuffer+BBZ.h"

@interface BBZImageSourceAction ()

@property (nonatomic, strong) BBZOutputSourceParam *outputSourceParam;

@end

@implementation BBZImageSourceAction
- (void)destroySomething {
    [((BBZImageAsset *)self.asset) unloadImage];
}

- (void)lock {
    [super lock];
    [((BBZImageAsset *)self.asset) loadImageWithCompletion:nil];
}

- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    if(!self.outputSourceParam) {
        self.outputSourceParam = [[BBZOutputSourceParam alloc] init];
        GPUImageFramebuffer *framebuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage:((BBZImageAsset *)self.asset).asset.CGImage];
        self.outputSourceParam.arrayFrameBuffer = @[framebuffer];
        
    }
}


- (BBZOutputSourceParam *)outputSourceAtTime:(CMTime)time {
    return self.outputSourceParam;
}

@end
