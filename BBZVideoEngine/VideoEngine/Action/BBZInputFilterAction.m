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
#import "GPUImageFramebuffer+BBZ.h"

@interface BBZInputFilterAction ()
@property (nonatomic, strong) BBZVideoInputFilter *multiFilter;
//@property (nonatomic, strong, readwrite) BBZTransformSourceNode *node;
@end


@implementation BBZInputFilterAction

- (instancetype)init {
    if(self = [super init]) {
        _transform = CGAffineTransformIdentity;
    }
    return self;
}

- (void)dealloc {
    [self.multiFilter removeAllCacheFrameBuffer];
    self.multiFilter = nil;
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
            framgmentShader = [BBZShader fragmentFBFectchRGBTransfromShader];
        } else {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentRGBTransfromShader];
//            vertexShader = [BBZShader vertextShader];
//            framgmentShader = [BBZShader fragmentPassthroughShader];

        }
    } else {
        if(bUseLastFB) {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentFBFectchYUV420FTransfromShader];
        } else {
            vertexShader = [BBZShader vertextTransfromShader];
            framgmentShader = [BBZShader fragmentYUV420FTransfromShader];
        }
    }
//    vertexShader = [BBZShader vertextShader];
//    framgmentShader = [BBZShader fragmentPassthroughShader];
    self.multiFilter = [[BBZVideoInputFilter alloc] initWithVertexShaderFromString:vertexShader fragmentShaderFromString:framgmentShader];
    self.multiFilter.renderSize = self.renderSize;
    self.multiFilter.bUseBackGroundImage = bUseLastFB;
    self.multiFilter.affineTransform = self.transform;
    self.multiFilter.bgFrameBuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage:self.node.image.CGImage];
    [self.multiFilter.bgFrameBuffer disableReferenceCounting];
}

- (void)setTransform:(CGAffineTransform)transform {
    _transform = transform;
    self.multiFilter.affineTransform = transform;
}

- (void)setRenderSize:(CGSize)renderSize {
    _renderSize = renderSize;
    self.multiFilter.renderSize = renderSize;
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
            GPUImageFramebuffer *firstFB = outputParam.arrayFrameBuffer[0];
            [self.multiFilter setInputFramebuffer:firstFB atIndex:0];
            for (GPUImageFramebuffer *fb in outputParam.arrayFrameBuffer) {
                if(fb == firstFB) {
                    continue;
                } else {
                    [self.multiFilter addFrameBuffer:fb];
                }
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
