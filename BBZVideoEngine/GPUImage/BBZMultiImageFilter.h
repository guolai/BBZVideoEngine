//
//  BBZMultiImageFilter.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/17.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBZMultiImageFilter : GPUImageFilter
@property (nonatomic, assign) GPUMatrix3x3 mat33ParamValue;
@property (nonatomic, assign) GPUVector4 vector4ParamValue1;
@property (nonatomic, assign) GPUVector4 vector4ParamValue2;

- (NSInteger)addImageTexture:(UIImage *)image;
- (BOOL)removeImageTexture:(UIImage *)image;

- (NSInteger)addFrameBuffer:(GPUImageFramebuffer *)frameBuffer;
- (BOOL)removeFrameBuffer:(GPUImageFramebuffer *)frameBuffer;

- (void)removeAllCacheFrameBuffer;

- (GLfloat *)adjustVertices:(GLfloat *)vertices;
- (GLfloat *)adjustTextureCoordinates:(GLfloat *)textureCoordinates;

@end

NS_ASSUME_NONNULL_END
