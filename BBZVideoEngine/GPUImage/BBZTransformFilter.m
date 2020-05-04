//
//  BBZTransformFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/4.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTransformFilter.h"
#import "GPUImageColorConversion.h"




NSString *const kBBZVideoRenderTransformVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform mat4 transformMatrix;
 uniform mat4 orthographicMatrix;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = transformMatrix * vec4(position.xy, 1.0, 1.0) * orthographicMatrix;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kBBZVideoRenderFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform mediump mat3 matParam;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     yuv.x = texture2D(inputImageTexture, textureCoordinate).r;
     yuv.yz = texture2D(inputImageTexture2, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = matParam * yuv;

     gl_FragColor = vec4(rgb, 1.0);
 }
 );


@interface BBZTransformFilter () {
    GLint _transformMatrixUniform;
    GLint _orthographicMatrixUniform;
    GPUMatrix4x4 _orthographicMatrix;
    GPUMatrix4x4 _transformMatrix;
    BOOL _isFullYUVRange;
    const GLfloat *_preferredConversion;
    
    GLint _bgfilterPositionAttribute, _bgfilterTextureCoordinateAttribute;
    GLint _bgfilterInputTextureUniform;
}

@property (nonatomic, assign, readwrite) BBZTransformType type;
@property (nonatomic, strong) GLProgram *bgFilterProgram;

@end


@implementation BBZTransformFilter

- (void)dealloc{
    BBZINFO(@"BBZTransformFilter dealloc");
}

- (instancetype)initWithTransfromType:(BBZTransformType)type {
    _type = type;
    if(_type == BBZTransformTypeImage) {
        self = [super initWithVertexShaderFromString:kBBZVideoRenderTransformVertexShaderString fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString];
    } else {
        self = [super initWithVertexShaderFromString:kBBZVideoRenderTransformVertexShaderString fragmentShaderFromString:kBBZVideoRenderFragmentShaderString];
        
        runSynchronouslyOnVideoProcessingQueue(^{
            self->_transformMatrixUniform = [self->filterProgram uniformIndex:@"transformMatrix"];
            self->_orthographicMatrixUniform = [self->filterProgram uniformIndex:@"orthographicMatrix"];
        });
    }
    _transform3D = CATransform3DIdentity;
    _preferredConversion = kColorConversion709;
    return self;
}

- (void)buildBackGroundParams {
    [GPUImageContext useImageProcessingContext];
    
    self.bgFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
    
    if (!self.bgFilterProgram.initialized)
    {
        [self.bgFilterProgram addAttribute:@"position"];
        [self.bgFilterProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.bgFilterProgram link])
        {
            NSString *progLog = [self.bgFilterProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [self.bgFilterProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [self.bgFilterProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            self.bgFilterProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    [GPUImageContext setActiveShaderProgram:self.bgFilterProgram];
    
    _bgfilterPositionAttribute = [self.bgFilterProgram attributeIndex:@"position"];
    _bgfilterTextureCoordinateAttribute = [self.bgFilterProgram attributeIndex:@"inputTextureCoordinate"];
    _bgfilterInputTextureUniform = [self.bgFilterProgram uniformIndex:@"inputImageTexture"];
    
    
}

- (void)setBUseBackGroundImage:(BOOL)bUseBackGroundImage {
    _bUseBackGroundImage = bUseBackGroundImage;
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self buildBackGroundParams];
    });
}

- (CGSize)sizeOfFBO {
    return self.renderSize;
}

- (CGSize)outputFrameSize {
    return self.renderSize;
}

- (void)setAffineTransform:(CGAffineTransform)newValue {
    self.transform3D = CATransform3DMakeAffineTransform(newValue);
}

- (CGAffineTransform)affineTransform {
    return CATransform3DGetAffineTransform(self.transform3D);
}

- (void)setTransform3D:(CATransform3D)newValue {
    _transform3D = newValue;
}


- (GLfloat *)adjustVertices:(GLfloat *)vertices {
    return vertices;
}

- (GLfloat *)adjustTextureCoordinates:(GLfloat *)textureCoordinates {
    return textureCoordinates;
}

- (void)drawBackGroundImage {
    [GPUImageContext setActiveShaderProgram:self.bgFilterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //draw bg
    static const GLfloat normalVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat normalTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, self.bgFrameBuffer.texture);
    glUniform1i(_bgfilterInputTextureUniform, 3);
    
    glVertexAttribPointer(_bgfilterPositionAttribute, 2, GL_FLOAT, 0, 0, normalVertices);
    glVertexAttribPointer(_bgfilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, normalTextureCoordinates);
    
    glEnableVertexAttribArray(_bgfilterPositionAttribute);
    glEnableVertexAttribArray(_bgfilterTextureCoordinateAttribute);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)renderVideo:(CMSampleBufferRef)sampleBuffer {
    runSynchronouslyOnVideoProcessingQueue(^{
        [self drawVideo:sampleBuffer];
    });
}

- (void)drawVideo:(CMSampleBufferRef)sampleBuffer {
    
    BOOL bDrawBackGround = NO;
    if(self.bUseBackGroundImage && self.bgFrameBuffer) {
        [self drawBackGroundImage];
        bDrawBackGround = YES;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    if (!_ignoreAspectRatio) {
        [self loadOrthoMatrix:(GLfloat *)&_orthographicMatrix left:-1.0 right:1.0 bottom:(-1.0 * self.renderSize.height / self.renderSize.width) top:(1.0 * self.renderSize.height / self.renderSize.width) near:-1.0 far:1.0];
    } else {
        [self loadOrthoMatrix:(GLfloat *)&_orthographicMatrix left:-1.0 right:1.0 bottom:-1.0 top:1.0 near:-1.0 far:1.0];
    }
    [self convert3DTransform:&_transform3D toMatrix:&_transformMatrix];
    
    if(!bDrawBackGround) {
        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    }
    
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture) {
        [outputFramebuffer lock];
    }
    
    
    CGFloat _imageBufferWidth;
    CGFloat _imageBufferHeight;
    GLuint _luminanceTexture;
    GLuint _chrominanceTexture;
    
    CVPixelBufferRef movieFrame = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferHeight = (int) CVPixelBufferGetHeight(movieFrame);
    int bufferWidth = (int) CVPixelBufferGetWidth(movieFrame);
    
    CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL) {
        if(CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            if (_isFullYUVRange) {
                _preferredConversion = kColorConversion601FullRange;
            } else {
                _preferredConversion = kColorConversion601;
            }
        } else {
            _preferredConversion = kColorConversion709;
        }
    } else {
        if (_isFullYUVRange) {
            _preferredConversion = kColorConversion601FullRange;
        } else {
            _preferredConversion = kColorConversion601;
        }
        
    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    
    if (CVPixelBufferGetPlaneCount(movieFrame) > 0) {// Check for YUV planar inputs to do RGB conversion
        CVPixelBufferLockBaseAddress(movieFrame,0);
        if ( (_imageBufferWidth != bufferWidth) && (_imageBufferHeight != bufferHeight) ) {
            _imageBufferWidth = bufferWidth;
            _imageBufferHeight = bufferHeight;
        }
        
        CVReturn err;
        // Y-plane
        glActiveTexture(GL_TEXTURE4);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
        
        
        if(err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        
        _luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
        
        glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // UV-plane
        glActiveTexture(GL_TEXTURE5);
        
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
        
        if (err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        
        _chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
        
        glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        CGFloat normalizedHeight = _imageBufferHeight / _imageBufferWidth;
        GLfloat adjustedVertices[] = {
            -1.0f, -normalizedHeight,
            1.0f, -normalizedHeight,
            -1.0f,  normalizedHeight,
            1.0f,  normalizedHeight,
        };
        
        static const GLfloat textureCoordinates[] = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            0.0f, 1.0f,
            1.0f, 1.0f,
        };
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
        glUniform1i(filterInputTextureUniform, 4);
        
        glActiveTexture(GL_TEXTURE5);
        glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
        glUniform1i(filterInputTexture2Uniform, 5);
        
        self.mat33ParamValue =  *((GPUMatrix3x3 *)_preferredConversion);
        if(_uniformMat33 >= 0) {
            GPUMatrix3x3 tmpMat33ParamValue = self.mat33ParamValue;
            glUniformMatrix3fv(_uniformMat33, 1, GL_FALSE, (GLfloat *)(&tmpMat33ParamValue));
        }
        if(_uniformV4[0] >= 0) {
            GPUVector4 tmpVector4ParamValue1 = self.vector4ParamValue1;
            glUniform4fv(_uniformV4[0], 1, (GLfloat *)&tmpVector4ParamValue1);
        }
        if(_uniformV4[1] >= 0) {
            GPUVector4 tmpVector4ParamValue2 = self.vector4ParamValue2;
            glUniform4fv(_uniformV4[1], 1, (GLfloat *)&tmpVector4ParamValue2);
        }
        
        glUniformMatrix4fv(_transformMatrixUniform, 1, GL_FALSE, (GLfloat *)&_transformMatrix);
        glUniformMatrix4fv(_orthographicMatrixUniform, 1, GL_FALSE, (GLfloat *)&_orthographicMatrix);
        
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, adjustedVertices);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
        CFRelease(luminanceTextureRef);
        CFRelease(chrominanceTextureRef);
    }
    
    
  
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, noRotationTextureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)renderImage:(GPUImageFramebuffer *)imageFrameBuffer {
    
}

#pragma mark  - Conversion from matrix formats

- (void)loadOrthoMatrix:(GLfloat *)matrix left:(GLfloat)left right:(GLfloat)right bottom:(GLfloat)bottom top:(GLfloat)top near:(GLfloat)near far:(GLfloat)far {
    GLfloat r_l = right - left;
    GLfloat t_b = top - bottom;
    GLfloat f_n = far - near;
    GLfloat tx = - (right + left) / (right - left);
    GLfloat ty = - (top + bottom) / (top - bottom);
    GLfloat tz = - (far + near) / (far - near);
    
    float scale = 2.0f;
    
    matrix[0] = scale / r_l;
    matrix[1] = 0.0f;
    matrix[2] = 0.0f;
    matrix[3] = tx;
    
    matrix[4] = 0.0f;
    matrix[5] = scale / t_b;
    matrix[6] = 0.0f;
    matrix[7] = ty;
    
    matrix[8] = 0.0f;
    matrix[9] = 0.0f;
    matrix[10] = scale / f_n;
    matrix[11] = tz;
    
    matrix[12] = 0.0f;
    matrix[13] = 0.0f;
    matrix[14] = 0.0f;
    matrix[15] = 1.0f;
}



- (void)convert3DTransform:(CATransform3D *)transform3D toMatrix:(GPUMatrix4x4 *)matrix {
    //    struct CATransform3D
    //    {
    //        CGFloat m11, m12, m13, m14;
    //        CGFloat m21, m22, m23, m24;
    //        CGFloat m31, m32, m33, m34;
    //        CGFloat m41, m42, m43, m44;
    //    };
    
    GLfloat *mappedMatrix = (GLfloat *)matrix;
    
    mappedMatrix[0] = (GLfloat)transform3D->m11;
    mappedMatrix[1] = (GLfloat)transform3D->m12;
    mappedMatrix[2] = (GLfloat)transform3D->m13;
    mappedMatrix[3] = (GLfloat)transform3D->m14;
    mappedMatrix[4] = (GLfloat)transform3D->m21;
    mappedMatrix[5] = (GLfloat)transform3D->m22;
    mappedMatrix[6] = (GLfloat)transform3D->m23;
    mappedMatrix[7] = (GLfloat)transform3D->m24;
    mappedMatrix[8] = (GLfloat)transform3D->m31;
    mappedMatrix[9] = (GLfloat)transform3D->m32;
    mappedMatrix[10] = (GLfloat)transform3D->m33;
    mappedMatrix[11] = (GLfloat)transform3D->m34;
    mappedMatrix[12] = (GLfloat)transform3D->m41;
    mappedMatrix[13] = (GLfloat)transform3D->m42;
    mappedMatrix[14] = (GLfloat)transform3D->m43;
    mappedMatrix[15] = (GLfloat)transform3D->m44;
}


@end
