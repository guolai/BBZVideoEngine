//
//  BBZInputFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/5.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZInputFilterAction.h"
#import "BBZVideoInputFilter.h"
#import "BBZTransformSourceNode.h"
#import "BBZShader.h"

@interface BBZInputFilterAction ()
@property (nonatomic, strong) BBZVideoInputFilter *multiFilter;
@property (nonatomic, strong, readwrite) BBZTransformSourceNode *node;
@end


@implementation BBZInputFilterAction


- (BBZTransformSourceNode *)node {
    return self.node;
}

- (void)createImageFilter {
    NSString *vertexShader = self.node.vShaderString;
    NSString *framgmentShader = self.node.fShaderString;
    BOOL bUseLastFB = NO;
    if(self.node.image) {
        bUseLastFB = YES;
    }
    if(self.node.bRGB) {
        if(bUseLastFB) {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentFBFectchYUV420FTransfromShader];
        } else {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentRGBTransfromShader];
        }
    } else {
        if(bUseLastFB) {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentFBFectchRGBTransfromShader];
        } else {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentYUV420FTransfromShader];
        }
    }
    self.multiFilter = [[BBZVideoInputFilter alloc] initWithVertexShaderFromString:vertexShader fragmentShaderFromString:framgmentShader];
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

- (void)removeConnects {
    [self.multiFilter removeAllTargets];
    self.firstInputSource = nil;
    self.secondInputSource = nil;
}

- (id)filter {
    return self.multiFilter;
}


- (void)connectToAction:(id<BBZActionChainProtocol>)toAction {
    [self.multiFilter addTarget:[toAction filter]];
}

@end
