//
//  BBZVideoOutputFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/11.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoOutputFilter.h"

@interface BBZVideoOutputFilter () {
    GLuint _movieFramebuffer;
    GLuint _movieRenderbuffer;
    CVPixelBufferRef _renderTarget;
    CVOpenGLESTextureRef _renderTexture;
}
@property (nonatomic, assign) CMTime frameTime;


@end

@implementation BBZVideoOutputFilter

- (void)dealloc {
    [self destroyDataFBO];
}

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

- (void)createDataFBO {
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &_movieFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _movieFramebuffer);
    
    CVPixelBufferPoolCreatePixelBuffer (NULL, [self.videoPixelBufferAdaptor pixelBufferPool], &_renderTarget);

    CVBufferSetAttachment(_renderTarget, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
    CVBufferSetAttachment(_renderTarget, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_601_4, kCVAttachmentMode_ShouldPropagate);
    CVBufferSetAttachment(_renderTarget, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, kCVAttachmentMode_ShouldPropagate);
    
    CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], _renderTarget,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA, // opengl format
                                                  (int)self.sizeOfFBO.width,
                                                  (int)self.sizeOfFBO.height,
                                                  GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &_renderTexture);
    
    glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);


    __unused GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
}

- (void)destroyDataFBO {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        if (_movieFramebuffer)
        {
            glDeleteFramebuffers(1, &_movieFramebuffer);
            _movieFramebuffer = 0;
        }
        
        if (_movieRenderbuffer)
        {
            glDeleteRenderbuffers(1, &_movieRenderbuffer);
            _movieRenderbuffer = 0;
        }
        
        if ([GPUImageContext supportsFastTextureUpload])
        {
            if (_renderTexture)
            {
                CFRelease((_renderTexture));
            }
            if (_renderTarget)
            {
                CVPixelBufferRelease(_renderTarget);
            }
            
        }
    });
}

- (void)setFilterFBO {
    if (_movieFramebuffer) {
        [self destroyDataFBO];
    }
    [self createDataFBO];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _movieFramebuffer);
    
    glViewport(0, 0, (int)self.sizeOfFBO.width, (int)self.sizeOfFBO.height);
}

#pragma mark - Filter

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
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
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }
    [self destroyDataFBO];
    [self setFilterFBO];

    if (usingNextFrameForImageCapture) {
        [outputFramebuffer lock];
    }

    [GPUImageContext setActiveShaderProgram:filterProgram];
    [self setUniformsForProgramAtIndex:0];
    if(self.shouldClearBackGround) {
        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 3);


    [self bindInputParamValues];

    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, [self adjustVertices:vertices]);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glFinish();
    [firstInputFramebuffer unlock];

    [self willEndRender];

    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    CVPixelBufferRef pixel_buffer = _renderTarget;

    CVPixelBufferLockBaseAddress(pixel_buffer, 0);
    if([self.delegate respondsToSelector:@selector(didDrawPixelBuffer:time:)]) {
        [self.delegate didDrawPixelBuffer:pixel_buffer time:self.frameTime];
    }
    CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
}

@end
