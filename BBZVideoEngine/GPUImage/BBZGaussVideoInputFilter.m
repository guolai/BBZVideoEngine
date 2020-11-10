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
    GLint _gaussFilterInputTextureUniform2;
    GLint _gaussTexelWidthUniform, _gaussTexelHeightUniform;
}

@property (nonatomic, strong) GLProgram *gaussFilterProgram;

@end

@implementation BBZGaussVideoInputFilter
- (void)dealloc{
    [self.bgFrameBuffer unlock];
    self.bgFrameBuffer = nil;
    BBZINFO(@"BBZVideoInputFilter dealloc");
}

- (instancetype)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString {
    if(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [self buildGaussFilterParams];
        });
    }
    return self;
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
    _gaussFilterInputTextureUniform2 = [self.gaussFilterProgram uniformIndex:@"inputImageTexture2"];
    [GPUImageContext setActiveShaderProgram:self.gaussFilterProgram];
    _gaussTexelWidthUniform = [self.gaussFilterProgram uniformIndex:@"texelWidthOffset"];
    _gaussTexelHeightUniform = [self.gaussFilterProgram uniformIndex:@"texelHeightOffset"];
    
}


- (void)processGaussImage {
    //否则，需要resize+blur
//    [GPUImageContext useImageProcessingContext];
//    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
//    secondOutputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
//    if (usingNextFrameForImageCapture) {
//        [outputFramebuffer lock];
//    }
//
//    //step1: resize
//    [GPUImageContext setActiveShaderProgram:filterProgram];
//    [filterProgram use];
//    [secondOutputFramebuffer activateFramebuffer];  //先画到second上面
//    [self setFloat:self.fDown forUniformName:@"resizeRatio"];
//    [self setFloat:0.0 forUniformName:@"bAddEdge"];
//    [self setFloat:0.0 forUniformName:@"fXLimit"];
//    //    [self setFloat:0.0 forUniformName:@"fYLimit"];
//
//    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
//    glClear(GL_COLOR_BUFFER_BIT);
//
//    glActiveTexture(GL_TEXTURE2);
//    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
//    glUniform1i(filterInputTextureUniform, 2);
//
//    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
//    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//
//    if (_blurRadius > 0){
//        //step2: gauss1
//        [GPUImageContext setActiveShaderProgram:secondFilterProgram];
//        [secondFilterProgram use];
//        [outputFramebuffer activateFramebuffer];
//        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
//        glClear(GL_COLOR_BUFFER_BIT);
//        if(self.blurDirction == BlurDirction_All || self.blurDirction == BlurDirction_Horizontal)
//        {
//            glUniform1f(gaussTexelWidthUniform, 1.0 / imageSize.width);
//        }
//        else
//        {
//            glUniform1f(gaussTexelWidthUniform, 0.0);
//        }
//        glUniform1f(gaussTexelHeightUniform, 0.0);
//
//        glActiveTexture(GL_TEXTURE2);
//        glBindTexture(GL_TEXTURE_2D, [secondOutputFramebuffer texture]);
//        glUniform1i(secondFilterInputTextureUniform, 2);
//
//        glVertexAttribPointer(secondFilterPositionAttribute, 2, GL_FLOAT, 0, 0, gaussVertex);
//        glVertexAttribPointer(secondFilterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, gaussFragment);
//        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//
//        //step3: gauss2
//        [secondOutputFramebuffer activateFramebuffer];
//        //        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
//        //        glClear(GL_COLOR_BUFFER_BIT);
//        glUniform1f(gaussTexelWidthUniform, 0.0);
//        if(self.blurDirction == BlurDirction_All || self.blurDirction == BlurDirction_Vertical)
//        {
//            glUniform1f(gaussTexelHeightUniform, 1.0 / imageSize.height);
//        }
//        else
//        {
//            glUniform1f(gaussTexelHeightUniform, 0.0);
//        }
//
//        glActiveTexture(GL_TEXTURE2);
//        glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
//        glUniform1i(secondFilterInputTextureUniform, 2);
//        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    }
    
}

- (void)willBeginRender {
    [self processGaussImage];
    [super willBeginRender];
}

- (void)willEndRender {
    [self.bgFrameBuffer unlock];
    self.bgFrameBuffer = nil;
}



@end
