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
 
 varying vec2 blurCoordinates[9];
 
 void main()
 {
    gl_Position = position;
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = inputTextureCoordinate.xy;
    blurCoordinates[1] = inputTextureCoordinate.xy + singleStepOffset * 1.458430;
    blurCoordinates[2] = inputTextureCoordinate.xy - singleStepOffset * 1.458430;
    blurCoordinates[3] = inputTextureCoordinate.xy + singleStepOffset * 3.403985;
    blurCoordinates[4] = inputTextureCoordinate.xy - singleStepOffset * 3.403985;
    blurCoordinates[5] = inputTextureCoordinate.xy + singleStepOffset * 5.351806;
    blurCoordinates[6] = inputTextureCoordinate.xy - singleStepOffset * 5.351806;
    blurCoordinates[7] = inputTextureCoordinate.xy + singleStepOffset * 7.302940;
    blurCoordinates[8] = inputTextureCoordinate.xy - singleStepOffset * 7.302940;
}
 );

NSString *const kBBZGaussVideoInputFragmentShader = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform highp float texelWidthOffset;
 uniform highp float texelHeightOffset;
 
 varying highp vec2 blurCoordinates[9];
 
 void main()
 {
    lowp vec4 sum = vec4(0.0);
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.133571;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.233308;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.233308;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.135928;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.135928;
    sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.051383;
    
    sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.051383;
    sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.012595;
    sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.012595;
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
    _yuvUniformMat33 = [self.yuvFilterProgram uniformIndex:@"matParam"];
    
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
    
    CGSize smallSize = self.rgbFrameBuffer.size;
    smallSize = CGSizeMake([self adjustVideoSizeValue:smallSize.width/8.0], [self adjustVideoSizeValue:smallSize.height/8.0]);
//    NSLog(@"processGaussImage size %@", NSStringFromCGSize(smallSize));
    
    GPUImageFramebuffer *frameBuffer1 = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:smallSize textureOptions:self.outputTextureOptions onlyTexture:NO];
    GPUImageFramebuffer *frameBuffer2 = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:smallSize textureOptions:self.outputTextureOptions onlyTexture:NO];
    [frameBuffer1 activateFramebuffer];
    
    [GPUImageContext setActiveShaderProgram:self.gaussFilterProgram];
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUniform1f(_gaussTexelWidthUniform, 0.0);
    glUniform1f(_gaussTexelHeightUniform, 0.0);

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [self.rgbFrameBuffer texture]);
    glUniform1i(_gaussFilterInputTextureUniform, 2);

    glVertexAttribPointer(_gaussFilterPositionAttribute, 2, GL_FLOAT, 0, 0, normalVertices);
    glVertexAttribPointer(_gaussFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, normalTextureCoordinates);
//    glEnableVertexAttribArray(_gaussFilterPositionAttribute);
//    glEnableVertexAttribArray(_gaussFilterTextureCoordinateAttribute);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
   
    [frameBuffer2 activateFramebuffer];


    glUniform1f(_gaussTexelWidthUniform, 1.0 / smallSize.width);
 
    glUniform1f(_gaussTexelHeightUniform, 0.0 );
 

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [frameBuffer1 texture]);
    glUniform1i(_gaussFilterInputTextureUniform, 2);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    

    [frameBuffer1 activateFramebuffer];
    
    
    glUniform1f(_gaussTexelWidthUniform, 0.0);
    
    glUniform1f(_gaussTexelHeightUniform, 1.0 / smallSize.height);
    
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [frameBuffer2 texture]);
    glUniform1i(_gaussFilterInputTextureUniform, 2);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    glFinish();
    self.bgFrameBuffer = frameBuffer1;
//    [frameBuffer1 unlock];
//    frameBuffer1 = nil;
    [frameBuffer2 unlock];
    frameBuffer2 = nil;
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
        self.rgbFrameBuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:firstInputFramebuffer.size textureOptions:self.outputTextureOptions onlyTexture:NO];
        [self.rgbFrameBuffer activateFramebuffer];
        [GPUImageContext setActiveShaderProgram:self.yuvFilterProgram];
        
        if(self.shouldClearBackGround) {
            glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, 1.0);
            glClear(GL_COLOR_BUFFER_BIT);
        }
        
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
        glUniform1i(_yuvFilterInputTextureUniform, 3);
        
        GPUImageFramebuffer *fb2 = [[self frameBuffers] objectAtIndex:0];
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [fb2 texture]);
        glUniform1i(_yuvFilterInputTextureUniform2, 4);
        
        GPUMatrix3x3 tmpmat33ParamValue = self.mat33ParamValue;
        glUniformMatrix3fv(_yuvUniformMat33, 1, GL_FALSE, (GLfloat *)(&tmpmat33ParamValue));
        
        
        glVertexAttribPointer(_yuvFilterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glVertexAttribPointer(_yuvFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
//        glEnableVertexAttribArray(_yuvFilterPositionAttribute);
//        glEnableVertexAttribArray(_yuvFilterTextureCoordinateAttribute);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
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
//    glEnableVertexAttribArray(filterPositionAttribute);
//    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
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
