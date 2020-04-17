//
//  GPUImageFramebuffer+BBZ.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/17.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "GPUImageFramebuffer+BBZ.h"
#import <GLKit/GLKit.h>
#import "GPUImage.h"


@implementation GPUImageFramebuffer (BBZ)

+ (GPUImageFramebuffer *)BBZ_frameBufferWithImage:(CGImageRef)image {
    @autoreleasepool {
        if (image == nil) {
            return nil;
        }
        
        CGImageRetain(image);
        int width = (int)CGImageGetWidth(image);
        int height = (int)CGImageGetHeight(image);
        
        if (width == 0 || height == 0) {
            NSAssert(NO, @"Invaild image size.");
            CGImageRelease(image);
            return nil;
        }
        
        Byte *contextData = calloc(1, width * height * 4);
        if (contextData == NULL) {
            NSAssert(NO, @"Failed to malloc data buffer...[size: %d KB]",width*height*4 >> 10);
            CGImageRelease(image);
            return nil;
        }
        
        static CGColorSpaceRef genericRGBColorspace = NULL;
        if (genericRGBColorspace == NULL) {
            genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        }
        
        CGContextRef bitmapContext = CGBitmapContextCreate(contextData, width, height, 8, width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationNone);
        CGContextDrawImage(bitmapContext, CGContextGetClipBoundingBox(bitmapContext), image);
        CGContextRelease(bitmapContext);
        
        GPUTextureOptions outputTextureOptions;
        outputTextureOptions.minFilter = GL_LINEAR;
        outputTextureOptions.magFilter = GL_LINEAR;
        outputTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
        outputTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
        outputTextureOptions.internalFormat = GL_RGBA;
        outputTextureOptions.format = GL_BGRA;
        outputTextureOptions.type = GL_UNSIGNED_BYTE;
        
        __block GPUImageFramebuffer *framebuffer;
        runSynchronouslyOnVideoProcessingQueue(^{
            framebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(width, height) textureOptions:outputTextureOptions onlyTexture:YES];
            glBindTexture(GL_TEXTURE_2D, [framebuffer texture]);
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         outputTextureOptions.internalFormat,
                         width,
                         height,
                         0,
                         outputTextureOptions.format,
                         outputTextureOptions.type,
                         contextData);
        });
        
        CGImageRelease(image);
        free(contextData);
        
        //NSLog(@"BBZ_frameBufferWithImage");
        
        return framebuffer;
    }
}

+ (GPUImageFramebuffer *)BBZ_frameBufferWithImageData:(void *)data width:(int)width height:(int)height {
    int bytesPerRow = width * 4;
    CVPixelBufferRef pixelBuffer = NULL;
    NSDictionary *attributes ;
    
    //ios9 以上
    attributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                   (id)kCVPixelBufferWidthKey: @(width),
                   (id)kCVPixelBufferHeightKey: @(height),
                   (id)kCVPixelBufferOpenGLESTextureCacheCompatibilityKey: @(YES),
                   (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
                   @"IOSurfaceOpenGLESTextureCompatibility": @(YES),
                   @"IOSurfaceOpenGLESFBOCompatibility": @(YES)};
    
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, data, bytesPerRow, NULL, NULL, (__bridge CFDictionaryRef)attributes, &pixelBuffer);
    
    return (pixelBuffer != NULL) ? [self BBZ_frameBufferWithCVPixelBuffer:pixelBuffer] : nil;
}

+ (GPUImageFramebuffer *)BBZ_frameBufferWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    GPUTextureOptions textureOptions;
    textureOptions.minFilter = GL_LINEAR;
    textureOptions.magFilter = GL_LINEAR;
    textureOptions.wrapS = GL_CLAMP_TO_EDGE;
    textureOptions.wrapT = GL_CLAMP_TO_EDGE;
    textureOptions.internalFormat = GL_RGBA;
    textureOptions.format = GL_BGRA;
    textureOptions.type = GL_UNSIGNED_BYTE;
    
    return [self BBZ_frameBufferWithCVPixelBuffer:pixelBuffer textureOptions:textureOptions];
}

+ (GPUImageFramebuffer *)BBZ_frameBufferWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer textureOptions:(GPUTextureOptions)textureOptions {
    if (pixelBuffer == NULL) {
        return nil;
    }
    
    GPUImageFramebuffer *outputFramebuffer;
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    if (bufferHeight <= 0) {
        NSLog(@"pixelBufferHeight:%d",bufferHeight);
        bufferHeight = 960;
    }
    if (bufferWidth <= 0)  {
        NSLog(@"pixelBufferWidth:%d",bufferWidth);
        bufferWidth = 540;
    }
    //NSLog(@"pixelBuffer size {%i * %i}", bufferWidth, bufferHeight);
    
    [GPUImageContext useImageProcessingContext];
    
    CVOpenGLESTextureRef textureRef = NULL;
    CVReturn rec = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, bufferWidth, bufferHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &textureRef);
    if (textureRef == NULL)
    {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage error: %d", rec);
        NSAssert(NO, @"CVOpenGLESTextureCacheCreateTextureFromImage error: %d", rec);
    }
    
    GLuint textureIndex = CVOpenGLESTextureGetName(textureRef);
    outputFramebuffer = [[GPUImageFramebuffer alloc] initWithSize:CGSizeMake(bufferWidth, bufferHeight) overriddenTexture:textureIndex renderTexture:textureRef];
    [outputFramebuffer disableReferenceCounting];
    glBindTexture(GL_TEXTURE_2D, textureIndex);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return outputFramebuffer;
}

+ (NSArray <GPUImageFramebuffer *>*)BBZ_YUVFrameBufferWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer == NULL) {
        return nil;
    }
    GPUTextureOptions textureOptions;
    textureOptions.minFilter = GL_LINEAR;
    textureOptions.magFilter = GL_LINEAR;
    textureOptions.wrapS = GL_CLAMP_TO_EDGE;
    textureOptions.wrapT = GL_CLAMP_TO_EDGE;
    textureOptions.internalFormat = GL_RGBA;
    textureOptions.format = GL_BGRA;
    textureOptions.type = GL_UNSIGNED_BYTE;
    GPUImageFramebuffer *YFramebuffer;
    GPUImageFramebuffer *UVFramebuffer;
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    if (bufferHeight <= 0) {
        NSLog(@"pixelBufferHeight:%d",bufferHeight);
        bufferHeight = 960;
    }
    if (bufferWidth <= 0)  {
        NSLog(@"pixelBufferWidth:%d",bufferWidth);
        bufferWidth = 540;
    }
    //NSLog(@"pixelBuffer size {%i * %i}", bufferWidth, bufferHeight);
    
    [GPUImageContext useImageProcessingContext];
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    GLint luminanceTexture;
    GLint chrominanceTexture;
    
    CVReturn rec = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
    if (luminanceTextureRef == NULL)
    {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage error: %d", rec);
        NSAssert(NO, @"CVOpenGLESTextureCacheCreateTextureFromImage error: %d", rec);
    }
    
    luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
    YFramebuffer = [[GPUImageFramebuffer alloc] initWithSize:CGSizeMake(bufferWidth, bufferHeight) overriddenTexture:luminanceTexture renderTexture:luminanceTextureRef];
    [YFramebuffer disableReferenceCounting];
    glBindTexture(GL_TEXTURE_2D, luminanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    rec = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
    if (chrominanceTextureRef == NULL)
    {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage2 error: %d", rec);
        NSAssert(NO, @"CVOpenGLESTextureCacheCreateTextureFromImage2 error: %d", rec);
    }
    
    chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
    UVFramebuffer = [[GPUImageFramebuffer alloc] initWithSize:CGSizeMake(bufferWidth/2, bufferHeight/2) overriddenTexture:chrominanceTexture renderTexture:chrominanceTextureRef];
    [UVFramebuffer disableReferenceCounting];
    glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    return @[YFramebuffer, UVFramebuffer];
}


+ (GPUImageFramebuffer *)BBZ_frameBufferWithYUVSinglePlaneData:(void *)data width:(int)width height:(int)height {
    if(!data) {
        return nil;
    }
    GPUTextureOptions textureOptions;
    textureOptions.minFilter = GL_LINEAR;
    textureOptions.magFilter = GL_LINEAR;
    textureOptions.wrapS = GL_CLAMP_TO_EDGE;
    textureOptions.wrapT = GL_CLAMP_TO_EDGE;
    textureOptions.internalFormat = GL_LUMINANCE;
    textureOptions.format = GL_LUMINANCE;
    textureOptions.type = GL_UNSIGNED_BYTE;
    
    [GPUImageContext useImageProcessingContext];
    if(width < 0 || height < 1) {
        NSAssert(FASYNC, @"width or height is invalid");
        return nil;
    }
    
    
    GPUImageFramebuffer *outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(width, height) textureOptions:textureOptions onlyTexture:YES];
    
    glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 textureOptions.internalFormat,
                 width,
                 height,
                 0,
                 textureOptions.format,
                 textureOptions.type,
                 data);
    return outputFramebuffer;
}

+ (GPUImageFramebuffer *)BBZ_frameBufferWithRGBAData:(void *)data width:(int)width height:(int)height {
    if(!data) {
        return nil;
    }
    GPUTextureOptions textureOptions;
    textureOptions.minFilter = GL_LINEAR;
    textureOptions.magFilter = GL_LINEAR;
    textureOptions.wrapS = GL_CLAMP_TO_EDGE;
    textureOptions.wrapT = GL_CLAMP_TO_EDGE;
    textureOptions.internalFormat = GL_RGBA;
    textureOptions.format = GL_RGBA;
    textureOptions.type = GL_UNSIGNED_BYTE;
    
    [GPUImageContext useImageProcessingContext];
    if(width < 0 || height < 1) {
        NSAssert(FASYNC, @"width or height is invalid");
        return nil;
    }
    
    GPUImageFramebuffer *outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(width, height) textureOptions:textureOptions onlyTexture:YES];
    
    glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 textureOptions.internalFormat,
                 width,
                 height,
                 0,
                 textureOptions.format,
                 textureOptions.type,
                 data);
    return outputFramebuffer;
}

- (void)BBZ_frameBufferUpdateYUVSinglePlaneData:(void *)data width:(int)width height:(int)height {
    if(!data) {
        return;
    }
    GPUTextureOptions textureOptions;
    textureOptions.minFilter = GL_LINEAR;
    textureOptions.magFilter = GL_LINEAR;
    textureOptions.wrapS = GL_CLAMP_TO_EDGE;
    textureOptions.wrapT = GL_CLAMP_TO_EDGE;
    textureOptions.internalFormat = GL_LUMINANCE;
    textureOptions.format = GL_LUMINANCE;
    textureOptions.type = GL_UNSIGNED_BYTE;
    
    [GPUImageContext useImageProcessingContext];
    if(width < 0 || height < 1) {
        NSAssert(false, @"width or height is invalid");
        return ;
    }
    NSAssert((width == self.size.width && height == self.size.height), @"size not equal");
    
    glBindTexture(GL_TEXTURE_2D, [self texture]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 textureOptions.internalFormat,
                 width,
                 height,
                 0,
                 textureOptions.format,
                 textureOptions.type,
                 data);
}

- (void)BBZ_frameBufferUpdateRGBAData:(void *)data width:(int)width height:(int)height {
    if(!data) {
        return ;
    }
    GPUTextureOptions textureOptions;
    textureOptions.minFilter = GL_LINEAR;
    textureOptions.magFilter = GL_LINEAR;
    textureOptions.wrapS = GL_CLAMP_TO_EDGE;
    textureOptions.wrapT = GL_CLAMP_TO_EDGE;
    textureOptions.internalFormat = GL_RGBA;
    textureOptions.format = GL_RGBA;
    textureOptions.type = GL_UNSIGNED_BYTE;
    
    [GPUImageContext useImageProcessingContext];
    if(width < 0 || height < 1) {
        NSAssert(FASYNC, @"width or height is invalid");
        return ;
    }
    NSAssert((width == self.size.width && height == self.size.height), @"size not equal");
    glBindTexture(GL_TEXTURE_2D, [self  texture]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 textureOptions.internalFormat,
                 width,
                 height,
                 0,
                 textureOptions.format,
                 textureOptions.type,
                 data);
}

@end

