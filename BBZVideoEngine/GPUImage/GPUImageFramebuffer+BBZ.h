//
//  GPUImageFramebuffer+BBZ.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/17.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "GPUImageFramebuffer.h"




NS_ASSUME_NONNULL_BEGIN


@interface GPUImageFramebuffer (BBZ)
+ (GPUImageFramebuffer *)BBZ_frameBufferWithImage:(CGImageRef)inputImage;


+ (GPUImageFramebuffer *)BBZ_frameBufferWithImageData:(void *)data width:(int)width height:(int)height;

+ (GPUImageFramebuffer *)BBZ_frameBufferWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;

+ (GPUImageFramebuffer *)BBZ_frameBufferWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer textureOptions:(GPUTextureOptions)textureOptions;

+ (NSArray <GPUImageFramebuffer *>*)BBZ_YUVFrameBufferWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;


+ (GPUImageFramebuffer *)BBZ_frameBufferWithYUVSinglePlaneData:(void *)data width:(int)width height:(int)height;


+ (GPUImageFramebuffer *)BBZ_frameBufferWithRGBAData:(void *)data width:(int)width height:(int)height;

- (void)BBZ_frameBufferUpdateYUVSinglePlaneData:(void *)data width:(int)width height:(int)height;

- (void)BBZ_frameBufferUpdateRGBAData:(void *)data width:(int)width height:(int)height;

@end

NS_ASSUME_NONNULL_END
