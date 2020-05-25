//
//  BBZInputFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/5.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZInputFilterAction.h"
#import "BBZVideoInputFilter.h"

@interface BBZInputFilterAction ()
@property (nonatomic, strong) BBZMultiImageFilter *multiFilter;
@end


@implementation BBZInputFilterAction


- (void)createImageFilter {
    self.multiFilter = [[BBZMultiImageFilter alloc] init];
}

- (BBZMultiImageFilter *)filter {
    return self.multiFilter;
}


//- (void)updateWithTime:(CMTime)time {
//
//}
//
//- (void)newFrameAtTime:(CMTime)time {
//
//}

- (void)processAVSourceAtTime:(CMTime)time {
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self.multiFilter removeAllCacheFrameBuffer];
        if(self.firstInputSource) {
            BBZInputSourceParam *outputParam = [self.firstInputSource inputSourceAtTime:time];
            for (GPUImageFramebuffer *fb in outputParam.arrayFrameBuffer) {
                [self.multiFilter addFrameBuffer:fb];
            }
            if(outputParam.bVideoSource) {
                self.multiFilter.mat33ParamValue = outputParam.mat33ParamValue;
            }
        }
        if(self.secondInputSource) {
            BBZInputSourceParam *outputParam = [self.secondInputSource inputSourceAtTime:time];
            for (GPUImageFramebuffer *fb in outputParam.arrayFrameBuffer) {
                [self.multiFilter addFrameBuffer:fb];
            }
            if(outputParam.bVideoSource) {
                self.multiFilter.mat33ParamValue = outputParam.mat33ParamValue;
            }
        }
        [self.multiFilter newFrameReadyAtTime:time atIndex:0];
    });
}

- (void)destroySomething {
    runSynchronouslyOnVideoProcessingQueue(^{
        [self.multiFilter removeAllCacheFrameBuffer];
        self.multiFilter = nil;
    });
}


@end
