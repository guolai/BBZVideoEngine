//
//  BBZGaussVideoInputFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/11/9.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZGaussVideoInputFilter.h"
#import "GPUImageColorConversion.h"
#import "BBZShader.h"

NSString *const kBBZGaussVideoInputVertexShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 blurCoordinates[5];
 
 void main()
 {
    gl_Position = position;
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = inputTextureCoordinate.xy;
    blurCoordinates[1] = inputTextureCoordinate.xy + singleStepOffset * 1.182425;
    blurCoordinates[2] = inputTextureCoordinate.xy - singleStepOffset * 1.182425;
    blurCoordinates[3] = inputTextureCoordinate.xy + singleStepOffset * 3.029312;
    blurCoordinates[4] = inputTextureCoordinate.xy - singleStepOffset * 3.029312;
}
 );

NSString *const kBBZGaussVideoInputFragmentShader = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform highp float texelWidthOffset;
 uniform highp float texelHeightOffset;
 
 varying highp vec2 blurCoordinates[5];
 
 void main()
 {
    lowp vec4 sum = vec4(0.0);
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.398943;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.295963;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.295963;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.004566;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.004566;
    gl_FragColor = sum;
}
 );


@interface BBZGaussVideoInputFilter () {
    GLint _gaussFilterPositionAttribute, _gaussFilterTextureCoordinateAttribute;
    GLint _gaussFilterInputTextureUniform;
    GLint _gaussTexelWidthUniform, _gaussTexelHeightUniform;
    
    GLint _yuvFilterPositionAttribute, _yuvFilterTextureCoordinateAttribute;
    GLint _yuvFilterInputTextureUniform;
    GLint _yuvFilterInputTextureUniform2;
    GLint _yuvUniformMat33;
    
}

@property (nonatomic, strong) GLProgram *gaussFilterProgram;
@property (nonatomic, strong) GLProgram *yuvFilterProgram;
@property (nonatomic, assign) BOOL bRGB;
@property (nonatomic, strong) GPUImageFramebuffer *rgbFrameBuffer;

@end

@implementation BBZGaussVideoInputFilter
- (void)dealloc{
    [self.bgFrameBuffer unlock];
    self.bgFrameBuffer = nil;
    BBZINFO(@"BBZVideoInputFilter dealloc");
}

- (instancetype)initWithRGBInput:(BOOL)bRGB {
    NSString *vertexShader = nil;
    NSString *framgmentShader = nil;
   
    vertexShader = [BBZShader vertextTransfromShader];
    framgmentShader = [BBZShader fragmentFBFectchRGBTransfromShader];

    if(self = [super initWithVertexShaderFromString:vertexShader fragmentShaderFromString:framgmentShader]) {
        self.bRGB = bRGB;
        runSynchronouslyOnVideoProcessingQueue(^{
            [self buildYUVFilterParams];
            [self buildGaussFilterParams];
        });
    }
    return self;
}

- (void)buildYUVFilterParams {
    if(self.bRGB) {
        return;
    }
    [GPUImageContext useImageProcessingContext];
    
    self.yuvFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:[BBZShader fragmentYUV420FTransfromShader]];
    
    if (!self.yuvFilterProgram.initialized)  {
        [self.yuvFilterProgram addAttribute:@"position"];
        [self.yuvFilterProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.yuvFilterProgram link]) {
            NSString *progLog = [self.yuvFilterProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [self.yuvFilterProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [self.yuvFilterProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            self.yuvFilterProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    [GPUImageContext setActiveShaderProgram:self.yuvFilterProgram];
    
    _yuvFilterPositionAttribute = [self.yuvFilterProgram attributeIndex:@"position"];
    _yuvFilterTextureCoordinateAttribute = [self.yuvFilterProgram attributeIndex:@"inputTextureCoordinate"];
    _yuvFilterInputTextureUniform = [self.yuvFilterProgram uniformIndex:@"inputImageTexture"];
    _yuvFilterInputTextureUniform2 = [self.yuvFilterProgram uniformIndex:@"inputImageTexture2"];
    NSString *uniformName  = @"matParam";
    GLint uniformIndex = [self.yuvFilterProgram uniformIndex:uniformName];
    self->_yuvUniformMat33 = uniformIndex;
    [GPUImageContext setActiveShaderProgram:self.yuvFilterProgram];
}

- (void)buildGaussFilterParams {
    [GPUImageContext useImageProcessingContext];
    
    self.gaussFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kBBZGaussVideoInputVertexShader fragmentShaderString:kBBZGaussVideoInputFragmentShader];
    
    if (!self.gaussFilterProgram.initialized)  {
        [self.gaussFilterProgram addAttribute:@"position"];
        [self.gaussFilterProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.gaussFilterProgram link]) {
            NSString *progLog = [self.gaussFilterProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [self.gaussFilterProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [self.gaussFilterProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            self.gaussFilterProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    [GPUImageContext setActiveShaderProgram:self.gaussFilterProgram];
    
    _gaussFilterPositionAttribute = [self.gaussFilterProgram attributeIndex:@"position"];
    _gaussFilterTextureCoordinateAttribute = [self.gaussFilterProgram attributeIndex:@"inputTextureCoordinate"];
    _gaussFilterInputTextureUniform = [self.gaussFilterProgram uniformIndex:@"inputImageTexture"];
    [GPUImageContext setActiveShaderProgram:self.gaussFilterProgram];
    _gaussTexelWidthUniform = [self.gaussFilterProgram uniformIndex:@"texelWidthOffset"];
    _gaussTexelHeightUniform = [self.gaussFilterProgram uniformIndex:@"texelHeightOffset"];
    
}


- (int)adjustVideoSizeValue:(CGFloat)fValue {
    int value = fValue;
    value = value - value % 2;
    return value;
}

- (void)processGaussImage {
    
    CGSize smallSize = [self sizeOfFBO];
    smallSize = CGSizeMake([self adjustVideoSizeValue:smallSize.width/4.0], [self adjustVideoSizeValue:smallSize.height/4.0]);
    NSLog(@"processGaussImage size %@", NSStringFromCGSize(smallSize));
    
    GPUImageFramebuffer *frameBuffer1 = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [frameBuffer1 activateFramebuffer];
    
    [GPUImageContext setActiveShaderProgram:self.gaussFilterProgram];
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    

    glUniform1f(_gaussTexelWidthUniform, 1.0 / smallSize.width);
    glUniform1f(_gaussTexelHeightUniform, 0.0);

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [self.rgbFrameBuffer texture]);
    glUniform1i(_gaussFilterInputTextureUniform, 2);

    glVertexAttribPointer(_gaussFilterPositionAttribute, 2, GL_FLOAT, 0, 0, gaussVertex);
    glVertexAttribPointer(_gaussFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, gaussFragment);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    //step3: gauss2
    [secondOutputFramebuffer activateFramebuffer];
    //        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    //        glClear(GL_COLOR_BUFFER_BIT);
    glUniform1f(gaussTexelWidthUniform, 0.0);
    if(self.blurDirction == BlurDirction_All || self.blurDirction == BlurDirction_Vertical)
    {
        glUniform1f(gaussTexelHeightUniform, 1.0 / imageSize.height);
    }
    else
    {
        glUniform1f(gaussTexelHeightUniform, 0.0);
    }

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
    glUniform1i(secondFilterInputTextureUniform, 2);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
}

- (void)willBeginRender {
    [self processGaussImage];
    [super willBeginRender];
}

- (void)willEndRender {
    if(self.rgbFrameBuffer == firstInputFramebuffer) {
        return;
    }
    [self.bgFrameBuffer unlock];
    self.bgFrameBuffer = nil;
}


#pragma mark - Render
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (self.preventRendering) {
        [firstInputFramebuffer unlock];
        return;
    }
    if(!self.bRGB) {
        self.rgbFrameBuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
        [self.rgbFrameBuffer activateFramebuffer];
        [GPUImageContext setActiveShaderProgram:self.yuvFilterProgram];
        
        if(self.shouldClearBackGround) {
            glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, 1.0);
            glClear(GL_COLOR_BUFFER_BIT);
        }
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
        glUniform1i(_yuvFilterInputTextureUniform, 2);
        
        GPUImageFramebuffer *fb2 = [[self frameBuffers] objectAtIndex:0];
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [fb2 texture]);
        glUniform1i(_yuvFilterInputTextureUniform2, 3);
        
        GPUMatrix3x3 tmpmat33ParamValue = self.mat33ParamValue;
        glUniformMatrix3fv(_yuvUniformMat33, 1, GL_FALSE, (GLfloat *)(&tmpmat33ParamValue));
        
        
        glVertexAttribPointer(_yuvFilterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glVertexAttribPointer(_yuvFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        
    }else {
        self.rgbFrameBuffer = firstInputFramebuffer;
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
    glBindTexture(GL_TEXTURE_2D, [self.rgbFrameBuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    [self bindInputParamValues];
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, [self adjustVertices:vertices]);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //    BBZINFO(@"renderToTextureWithVertices %p, %p, %@, %@", firstInputFramebuffer, outputFramebuffer, self.debugName, self);
    //    BBZINFO(@"renderToTexture1 %@", firstInputFramebuffer.debugDescription);
    //    BBZINFO(@"renderToTexture2 %@", outputFramebuffer.debugDescription);
    [firstInputFramebuffer unlock];
    
    [self willEndRender];
    //    glFinish();
    //    if([self.debugName isEqualToString:@"transition"]) {
    //        BBZLOG();
    //    }
    if (usingNextFrameForImageCapture) {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
