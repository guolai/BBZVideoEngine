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


+ (CVPixelBufferRef)BBZ_pixelBufferWithCGImage:(CGImageRef)image{

    int width = (int)CGImageGetWidth(image);
    int height = (int)CGImageGetHeight(image);
    if ((width == 0) || (height == 0))
    {
        return NULL;
    }
    
    NSDictionary *attributes;
    if ([UIDevice currentDevice].systemVersion.floatValue>=9.0)
    {
        attributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                       (id)kCVPixelBufferWidthKey: @(width),
                       (id)kCVPixelBufferHeightKey: @(height),
                       (id)kCVPixelBufferOpenGLESTextureCacheCompatibilityKey: @(YES),
                       (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
                       @"IOSurfaceOpenGLESTextureCompatibility": @(YES),
                       @"IOSurfaceOpenGLESFBOCompatibility": @(YES)};
    }
    else
    {
        attributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                       (id)kCVPixelBufferWidthKey: @(width),
                       (id)kCVPixelBufferHeightKey: @(height),
                       @"OpenGLESTextureCacheCompatibility": @(YES),
                       (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
                       @"IOSurfaceOpenGLESTextureCompatibility": @(YES),
                       @"IOSurfaceOpenGLESFBOCompatibility": @(YES)};
    }
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)attributes, &pixelBuffer);
    if (result != noErr)
    {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace, ((CGBitmapInfo)kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}


+ (GPUImageFramebuffer *)BBZ_frameBufferWithImage:(CGImageRef)inputImage {
    @autoreleasepool {
        if (inputImage == nil) {
            return nil;
        }
        NSError *error;
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:inputImage options:nil error:&error];
        if (error) {
            //        NSAssert(NO, @"load image failed...%@",*error);
            NSLog(@"error : %@",error);
            
            int width = roundf(CGImageGetWidth(inputImage));
            int height = roundf(CGImageGetHeight(inputImage));
            
            UIGraphicsBeginImageContext(CGSizeMake(width, height));
            [[UIImage imageWithCGImage:inputImage] drawInRect:CGRectMake(0, 0, width, height)];
            UIImage *imageref = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            error = nil;
            textureInfo = [GLKTextureLoader textureWithCGImage:imageref.CGImage options:nil error:&error];
        }
        
        GPUImageFramebuffer *frameBuffer = [[GPUImageFramebuffer alloc]
                                            initWithSize:CGSizeMake(CGImageGetWidth(inputImage), CGImageGetHeight(inputImage))
                                            overriddenTexture:textureInfo.name];
        
        return frameBuffer;
    }
}

+ (GPUImageFramebuffer *)BBZ_frameBufferWithImage2:(CGImageRef)inputImage {
    CVPixelBufferRef pixelBuffer = [GPUImageFramebuffer BBZ_pixelBufferWithCGImage:inputImage];
    GPUImageFramebuffer *frameBuffer = [GPUImageFramebuffer BBZ_frameBufferWithCVPixelBuffer:pixelBuffer];
    CFRelease(pixelBuffer);
    return frameBuffer;
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

