//
//  BBZVideoOutputFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/11.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoOutputFilter.h"

@interface BBZVideoOutputFilter ()
@property (nonatomic, assign) CMTime frameTime;

@end

@implementation BBZVideoOutputFilter

- (instancetype)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString {
    self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString];
    return self;
}

- (CGSize)sizeOfFBO {
    if(CGSizeEqualToSize(CGSizeZero, self.outputVideoSize)) {
        return [super sizeOfFBO];
    }
    return self.outputVideoSize;
}

- (CGSize)outputFrameSize {
    if(CGSizeEqualToSize(CGSizeZero, self.outputVideoSize)) {
        return [super outputFrameSize];
    }
    return self.outputVideoSize;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    self.frameTime = frameTime;
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if(self.bShouldDrawAgain) {
        //    CGFloat scale =  1.0;
        //    self.vector4ParamValue1 =  (SSZGPUVector4){self.waterBounds.origin.x / self.originVideoSize.width, self.waterBounds.origin.y * scale / self.originVideoSize.height, self.waterBounds.size.width / self.originVideoSize.width, self.waterBounds.size.height * scale / self.originVideoSize.height};
        [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
    } else {
        outputFramebuffer = firstInputFramebuffer;
    }
    glFinish();
    if([self.delegate respondsToSelector:@selector(didDrawFrameBuffer:time:)]) {
        [self.delegate didDrawFrameBuffer:outputFramebuffer time:self.frameTime];
    }
    [outputFramebuffer unlock];
    outputFramebuffer = nil;
    
}

@end
