//
//  BBZMultiImageFilter.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/17.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "GPUImageFilter.h"

@interface BBZMultiImageFilter : GPUImageFilter {
    GLint _uniformTextures[5];
    GLint _uniformMat33;
    GLint _uniformV4[2];
    GLint _uniformMat441;
    GLint _uniformMat442;
}
@property (nonatomic, assign) GPUMatrix3x3 mat33ParamValue;
@property (nonatomic, assign) GPUVector4 vector4ParamValue1;
@property (nonatomic, assign) GPUVector4 vector4ParamValue2;
@property (nonatomic, assign) GPUMatrix4x4 mat44ParamValue1;
@property (nonatomic, assign) GPUMatrix4x4 mat44ParamValue2;
@property (nonatomic, assign) BOOL shouldClearBackGround;

- (NSInteger)addImageTexture:(UIImage *)image;
- (BOOL)removeImageTexture:(UIImage *)image;

- (NSInteger)addFrameBuffer:(GPUImageFramebuffer *)frameBuffer;
- (BOOL)removeFrameBuffer:(GPUImageFramebuffer *)frameBuffer;

- (void)removeAllCacheFrameBuffer;


- (NSArray<GPUImageFramebuffer *> *)frameBuffers;
- (const GLfloat *)adjustVertices:(const GLfloat *)vertices;
- (const GLfloat *)adjustTextureCoordinates:(const GLfloat *)textureCoordinates;


- (void)willBeginRender;
- (void)willEndRender;


@end
