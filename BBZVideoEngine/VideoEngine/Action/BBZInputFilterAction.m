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
#import "BBZGaussVideoInputFilter.h"


@implementation BBZInputFilterAction

- (instancetype)init {
    if(self = [super init]) {
//        _transform = CGAffineTransformIdentity;
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
    BBZVideoInputFilter *videoMultiFilter = nil;
    if(self.node.useGaussImage) {
        videoMultiFilter = [[BBZGaussVideoInputFilter alloc] initWithRGBInput:self.node.bRGB];
        videoMultiFilter.renderSize = self.renderSize;
        videoMultiFilter.bUseBackGroundImage = YES;
        videoMultiFilter.fillType = self.fillType;
    } else {
        videoMultiFilter = [[BBZVideoInputFilter alloc] initWithVertexShaderFromString:vertexShader fragmentShaderFromString:framgmentShader];
        videoMultiFilter.renderSize = self.renderSize;
        videoMultiFilter.bUseBackGroundImage = bUseLastFB;
        videoMultiFilter.fillType = self.fillType;
        videoMultiFilter.bgFrameBuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage:self.node.image.CGImage];
        [videoMultiFilter.bgFrameBuffer disableReferenceCounting];
    }
    videoMultiFilter.debugName = NSStringFromClass([videoMultiFilter class]);
    self.multiFilter = videoMultiFilter;
}

- (void)setFillType:(BBZVideoFillModeType)fillType {
    _fillType = fillType;
    ((BBZVideoInputFilter *)self.multiFilter).fillType = fillType;
}

//- (void)setTransform:(CGAffineTransform)transform {
//    _transform = transform;
//    self.videoMultiFilter.affineTransform = transform;
//}

- (void)setRenderSize:(CGSize)renderSize {
    [super setRenderSize:renderSize];
    ((BBZVideoInputFilter *)self.multiFilter).renderSize = renderSize;
}

- (void)updateWithTime:(CMTime)time {
    NSTimeInterval relativeTime = [self relativeTimeFrom:time];
    BBZNodeAnimationParams *params = [self.node paramsAtTime:relativeTime];
    if(!params) {
        return;
    }
    if(!self.node.name) {
        return;
    }
    if([self.node.name isEqualToString:BBZFilterTransformSource]) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, params.param2, params.param3);
        transform = CGAffineTransformScale(transform, params.param1, params.param1);
        transform = CGAffineTransformRotate(transform, params.param4*2.0*M_PI/360.0);
        ((BBZVideoInputFilter *)self.multiFilter).affineTransform = transform;
    }
//            CGRect rect = [params frame];
//            self.multiFilter.vector4ParamValue1 = (GPUVector4){rect.origin.x/self.renderSize.width, rect.origin.y/self.renderSize.height, rect.size.width/self.renderSize.width, rect.size.height/self.renderSize.height};
    
    
}

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
//        if(self.secondInputSource) {
//            BBZInputSourceParam *outputParam = [self.secondInputSource inputSourceAtTime:time];
//            for (GPUImageFramebuffer *fb in outputParam.arrayFrameBuffer) {
//                [self.videoMultiFilter addFrameBuffer:fb];
//            }
//            if(outputParam.bVideoSource) {
//                self.videoMultiFilter.mat33ParamValue = outputParam.mat33ParamValue;
//            }
//        }
//        NSLog(@"newFrameReadyAtTime %p", self);
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
//    self.secondInputSource = nil;
}

- (id)filter {
    return self.multiFilter;
}


- (void)connectToAction:(id<BBZActionChainProtocol>)toAction {
    [self.multiFilter addTarget:[toAction filter]];
}

@end
