//
//  BBZGaussInputFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/11/9.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZGaussInputFilterAction.h"
#import "BBZGaussVideoInputFilter.h"
#import "BBZTransformSourceNode.h"
#import "BBZShader.h"
#import "GPUImageFramebuffer+BBZ.h"

@implementation BBZGaussInputFilterAction


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
  
    BBZGaussVideoInputFilter *videoMultiFilter = [[BBZGaussVideoInputFilter alloc] initWithVertexShaderFromString:vertexShader fragmentShaderFromString:framgmentShader];
    videoMultiFilter.renderSize = self.renderSize;
    videoMultiFilter.bUseBackGroundImage = bUseLastFB;
    videoMultiFilter.fillType = self.fillType;
    videoMultiFilter.bgFrameBuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage:self.node.image.CGImage];
    [videoMultiFilter.bgFrameBuffer disableReferenceCounting];
    videoMultiFilter.debugName = NSStringFromClass([videoMultiFilter class]);
    self.multiFilter = videoMultiFilter;
}



@end
