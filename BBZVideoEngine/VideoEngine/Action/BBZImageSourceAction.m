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

@property (nonatomic, strong) BBZInputSourceParam *inputSourceParam;

@end


@implementation BBZImageSourceAction


- (void)destroySomething {
    [((BBZImageAsset *)self.asset) unloadImage];
}

- (void)lock {
    [super lock];
    if(!((BBZImageAsset *)self.asset).asset) {
        [((BBZImageAsset *)self.asset) loadImageWithCompletion:nil];
    }
    
}

- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    runSynchronouslyOnVideoProcessingQueue(^{
        if(!self.inputSourceParam) {
            self.inputSourceParam = [[BBZInputSourceParam alloc] init];
            GPUImageFramebuffer *framebuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage2:((BBZImageAsset *)self.asset).asset.CGImage];
            self.inputSourceParam.arrayFrameBuffer = @[framebuffer];
        }
    });
}


- (BBZInputSourceParam *)inputSourceAtTime:(CMTime)time {
    return self.inputSourceParam;
}



@end
