//
//  BBZMultiImageFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/17.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZMultiImageFilter.h"
#import "GPUImageFramebuffer+BBZ.h"


@interface BBZMultiImageFilter ()
@property (nonatomic, strong) NSMutableArray *objectsArray;
@property (nonatomic, strong) NSMutableArray <GPUImageFramebuffer *>*frameBufferArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger maxIndex;
@end

@implementation BBZMultiImageFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString {
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString])) {
        return nil;
    }
    _objectsArray = [NSMutableArray array];
    _frameBufferArray = [NSMutableArray array];
    _maxIndex = 5;
    _index = 1;
    backgroundColorAlpha = 1.0;
    _shouldClearBackGround = NO;
    _fenceCount = 1;
    runSynchronouslyOnVideoProcessingQueue(^{
        [self resetFence];
        [GPUImageContext useImageProcessingContext];
        self->_uniformTextures[0] = self->filterInputTextureUniform;
        for (int i = 1; i < self->_maxIndex; i++) {
            NSString *uniformName = [NSString stringWithFormat:@"inputImageTexture%d", i+1];
            GLint uniformTexture = [self->filterProgram uniformIndex:uniformName];
            self->_uniformTextures[i] = uniformTexture;
            NSLog(@"bob -- _uniformTextures %d :%d, %@", i, uniformTexture, uniformName);
        }
        {
            NSString *uniformName  = @"matParam";
            GLint uniformIndex = [self->filterProgram uniformIndex:uniformName];
            self->_uniformMat33 = uniformIndex;
            NSLog(@"bob -- _uniformMat33 :%d", uniformIndex);
        }
        {
            NSString *uniformName  = @"matParam441";
            GLint uniformIndex = [self->filterProgram uniformIndex:uniformName];
            self->_uniformMat441 = uniformIndex;
            NSLog(@"bob -- _uniformMat441 :%d", uniformIndex);
            
            uniformName  = @"matParam442";
            uniformIndex = [self->filterProgram uniformIndex:uniformName];
            self->_uniformMat442 = uniformIndex;
            NSLog(@"bob -- _uniformMat442 :%d", uniformIndex);
        }
        
        for (int i = 0; i < 2; i++) {
            NSString *uniformName = [NSString stringWithFormat:@"v4Param%d", i+1];
            GLint uniformTexture = [self->filterProgram uniformIndex:uniformName];
            self->_uniformV4[i] = uniformTexture;
            NSLog(@"bob -- _uniformV4 %d :%d", i, uniformTexture);
        }
    });
    return self;
}



- (NSInteger)addImageTexture:(UIImage *)image {
    NSInteger resultIndex = -1;
    if(!image) {
        return resultIndex;
    }
    NSAssert(self.index + 1 <= self.maxIndex, @"texture too much");
    runSynchronouslyOnVideoProcessingQueue(^{
        self.index ++;
        [self.objectsArray addObject:image];
        GPUImageFramebuffer *frameBuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage:image.CGImage];
        [frameBuffer disableReferenceCounting];
        [self.frameBufferArray addObject:frameBuffer];
    });
    resultIndex = self.objectsArray.count;
    return resultIndex;
}
- (BOOL)removeImageTexture:(UIImage *)image {
    __block BOOL bRet = NO;
    runSynchronouslyOnVideoProcessingQueue(^{
        if([self.objectsArray containsObject:image]) {
            NSInteger objectIndex = [self.objectsArray indexOfObject:image];
            [self.objectsArray removeObject:image];
            [self.frameBufferArray removeObjectAtIndex:objectIndex];
            self.index --;
            bRet = YES;
        }
    });
    NSAssert(self.index >= 1, @"error happend");
    return bRet;
}

- (void)addFrameBuffer:(GPUImageFramebuffer *)frameBuffer atIndex:(NSInteger)index {
    if(!frameBuffer) {
        return;
    }
    NSAssert(self.index + 1 <= self.maxIndex, @"texture too much");
    runSynchronouslyOnVideoProcessingQueue(^{
        if([self.objectsArray containsObject:frameBuffer]){
            [self removeFrameBuffer:frameBuffer];
        }
        self.index ++;
        [self.objectsArray addObject:frameBuffer];
        if(index > self.frameBufferArray.count) {
            [self.frameBufferArray addObject:frameBuffer];
        } else {
            [self.frameBufferArray insertObject:frameBuffer atIndex:index];
        }
    });
}

- (NSInteger)addFrameBuffer:(GPUImageFramebuffer *)frameBuffer {
    NSInteger resultIndex = -1;
    if(!frameBuffer) {
        return resultIndex;
    }
    NSAssert(self.index + 1 <= self.maxIndex, @"texture too much");
    runSynchronouslyOnVideoProcessingQueue(^{
        if([self.objectsArray containsObject:frameBuffer]){
            [self removeFrameBuffer:frameBuffer];
        }
        self.index ++;
        [self.objectsArray addObject:frameBuffer];
        [self.frameBufferArray addObject:frameBuffer];
    });
    resultIndex = self.objectsArray.count;
    return resultIndex;
}

- (BOOL)removeFrameBuffer:(GPUImageFramebuffer *)frameBuffer {
    __block BOOL bRet = NO;
    runSynchronouslyOnVideoProcessingQueue(^{
        if([self.objectsArray containsObject:frameBuffer]) {
            NSInteger objectIndex = [self.objectsArray indexOfObject:frameBuffer];
            [self.objectsArray removeObject:frameBuffer];
            [self.frameBufferArray removeObjectAtIndex:objectIndex];
            self.index --;
            bRet = YES;
        }
    });
    NSAssert(self.index >= 1, @"error happend");
    return bRet;
}


#pragma mark - BBZGPUFilter

- (const GLfloat *)adjustVertices:(const GLfloat *)vertices {
    return vertices;
}

- (const GLfloat *)adjustTextureCoordinates:(const GLfloat *)textureCoordinates {
    return textureCoordinates;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    
    [self willBeginRender];
    
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture) {
        [outputFramebuffer lock];
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    [self setUniformsForProgramAtIndex:0];
    if(self.shouldClearBackGround) {
        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    NSInteger uniformIndex = 1;
    GLint textureIndex = 1;
    for (GPUImageFramebuffer *fb in self.frameBufferArray) {
        glActiveTexture(GL_TEXTURE2 + textureIndex);
        glBindTexture(GL_TEXTURE_2D, [fb texture]);
        glUniform1i(_uniformTextures[uniformIndex], 2 + textureIndex);
        uniformIndex++;
        textureIndex++;
    }
    if(_uniformMat33 >= 0) {
        glUniformMatrix3fv(_uniformMat33, 1, GL_FALSE, (GLfloat *)(&_mat33ParamValue));
    }
    if(_uniformMat441 >= 0) {
        glUniformMatrix4fv(_uniformMat441, 1, GL_FALSE, (GLfloat *)(&_mat44ParamValue1));
    }
    if(_uniformMat442 >= 0) {
        glUniformMatrix4fv(_uniformMat442, 1, GL_FALSE, (GLfloat *)(&_mat44ParamValue2));
    }
    if(_uniformV4[0] >= 0) {
        glUniform4fv(_uniformV4[0], 1, (GLfloat *)&_vector4ParamValue1);
    }
    if(_uniformV4[1] >= 0) {
        glUniform4fv(_uniformV4[1], 1, (GLfloat *)&_vector4ParamValue2);
    }
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, [self adjustVertices:vertices]);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glFinish();
    [firstInputFramebuffer unlock];
    
    [self willEndRender];
    
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)removeAllCacheFrameBuffer {
    runSynchronouslyOnVideoProcessingQueue(^{
        self.index = 1;
        [self.objectsArray removeAllObjects];
        [self.frameBufferArray removeAllObjects];
    });
}

- (NSArray<GPUImageFramebuffer *> *)frameBuffers {
    return self.frameBufferArray;
}

- (void)willBeginRender {
}

- (void)willEndRender {

}

- (void)resetFence {
    _fence[0] = 0;
    _fence[1] = 0;
    _fence[2] = 0;
    _fence[3] = 0;
    _fence[4] = 0;
    _fence[5] = 0;
}

- (BOOL)checkNewFrameReady {
    BOOL bReady = YES;
    for (int i = 0; i < self.fenceCount; i++) {
        if(_fence[i] == 0) {
            bReady = NO;
            break;
        }
    }
    return bReady;
}

#pragma mark - parent
- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    if(self.fenceCount < 2) {
        [super setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
        return;
    }
    if(textureIndex != 0) {
        [self addFrameBuffer:newInputFramebuffer atIndex:textureIndex];
    } else {
//        if(firstInputFramebuffer && firstInputFramebuffer != newInputFramebuffer) {
//            NSInteger index =  [self addFrameBuffer:newInputFramebuffer];
//            if(index != -1) {
//                _fence[index] = 1;
//            }
//        } else {
            [super setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
//            _fence[textureIndex] = 1;
//        }
        
    }
}


- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if(self.fenceCount < 2) {
        [super newFrameReadyAtTime:frameTime atIndex:0];
        return;
    }
    if([self checkNewFrameReady]) {
        return;
    }
    _fence[textureIndex] = 1;
    if ([self checkNewFrameReady]) {
        [super newFrameReadyAtTime:frameTime atIndex:0];
        [self resetFence];
    } else {
        NSLog(@"sdfas");
    }
}

@end

