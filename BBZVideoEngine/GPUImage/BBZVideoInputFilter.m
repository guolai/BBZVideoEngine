//
//  BBZVideoInputFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/4.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoInputFilter.h"
#import "GPUImageColorConversion.h"
#import "BBZShader.h"


@interface BBZVideoInputFilter () {
    GLint _bgfilterPositionAttribute, _bgfilterTextureCoordinateAttribute;
    GLint _bgfilterInputTextureUniform;
    GLfloat _imageVertices[8];
}

//@property (nonatomic, assign, readwrite) BBZVideoInputType type;
@property (nonatomic, strong) GLProgram *bgFilterProgram;

@end


@implementation BBZVideoInputFilter

- (void)dealloc{
    [self.bgFrameBuffer unlock];
    self.bgFrameBuffer = nil;
    BBZINFO(@"BBZVideoInputFilter dealloc");
}

- (instancetype)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString {
    if(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]) {
        self.transform3D = CATransform3DIdentity;
        self.fillType = BBZVideoFillModePreserveAspectRatio;
    }
    return self;
}


- (void)buildBackGroundParams {
    [GPUImageContext useImageProcessingContext];
    
    self.bgFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
    
    if (!self.bgFilterProgram.initialized)  {
        [self.bgFilterProgram addAttribute:@"position"];
        [self.bgFilterProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.bgFilterProgram link]) {
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
    if(_bUseBackGroundImage) {
        runAsynchronouslyOnVideoProcessingQueue(^{
            [self buildBackGroundParams];
        });
    } else {
        self.shouldClearBackGround = YES;
    }
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
    runAsynchronouslyOnVideoProcessingQueue(^{
        GPUMatrix4x4 matrix;
        [self convert3DTransform:&self->_transform3D toMatrix:&matrix];
        self.mat44ParamValue2 = matrix;
    });
}


- (void)updateFillType {
    
    CGFloat heightScaling, widthScaling;
    CGSize textureSize = firstInputFramebuffer.size;
    CGRect bounds = CGRectMake(0, 0, self.renderSize.width, self.renderSize.height);
    CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(textureSize, bounds);
    
    switch(self.fillType) {
        case BBZVideoFillModeStretch: {
            widthScaling = 1.0;
            heightScaling = 1.0;
        }; break;
        case BBZVideoFillModePreserveAspectRatio: {
            widthScaling = insetRect.size.width / self.renderSize.width;
            heightScaling = insetRect.size.height / self.renderSize.height;
        }; break;
        case BBZVideoFillModePreserveAspectRatioAndFill: {
            widthScaling = self.renderSize.height / insetRect.size.height;
            heightScaling = self.renderSize.width / insetRect.size.width;
        }; break;
    }
    GPUMatrix4x4 matrix;
    if(fabs(widthScaling - 1.0) < 0.00001 && fabs(heightScaling - 1.0) < 0.00001) {
        [self loadOrthoMatrix:(GLfloat *)&matrix left:-1.0 right:1.0 bottom:-1.0 top:1.0 near:-1.0 far:1.0];
        _imageVertices[0] = -1.0;
        _imageVertices[1] = -1.0;
        _imageVertices[2] = 1.0;
        _imageVertices[3] = -1.0;
        _imageVertices[4] = -1.0;
        _imageVertices[5] = 1.0;
        _imageVertices[6] = 1.0;
        _imageVertices[7] = 1.0;
    } else if(fabs(widthScaling - 1.0) < 0.00001) {
        [self loadOrthoMatrix:(GLfloat *)&matrix left:-1.0 * (self.renderSize.width / self.renderSize.height) right:1.0 * (self.renderSize.width / self.renderSize.height) bottom:-1.0  top:1.0 near:-1.0 far:1.0];
        CGFloat normalizedWidth = textureSize.width / textureSize.height;
        _imageVertices[0] = -1.0 * normalizedWidth;
        _imageVertices[1] = -1.0;
        _imageVertices[2] = 1.0 * normalizedWidth;
        _imageVertices[3] = -1.0;
        _imageVertices[4] = -1.0 * normalizedWidth;
        _imageVertices[5] = 1.0;
        _imageVertices[6] = 1.0 * normalizedWidth;
        _imageVertices[7] = 1.0;
        
    } else {
        [self loadOrthoMatrix:(GLfloat *)&matrix left:-1.0 right:1.0 bottom:(-1.0 * self.renderSize.height / self.renderSize.width) top:(1.0 * self.renderSize.height / self.renderSize.width) near:-1.0 far:1.0];
        CGFloat normalizedHeight = textureSize.height / textureSize.width;
        _imageVertices[0] = -1.0;
        _imageVertices[1] = -1.0 * normalizedHeight;
        _imageVertices[2] = 1.0;
        _imageVertices[3] = -1.0 * normalizedHeight;
        _imageVertices[4] = -1.0;
        _imageVertices[5] = 1.0 * normalizedHeight;
        _imageVertices[6] = 1.0;
        _imageVertices[7] = 1.0 * normalizedHeight;
    }
    self.mat44ParamValue1 = matrix;
}


- (const GLfloat *)adjustVertices:(const GLfloat *)vertices {
    return _imageVertices;
}

- (const GLfloat *)adjustTextureCoordinates:(const GLfloat *)textureCoordinates {
    return textureCoordinates;
}

- (void)drawBackGroundImage {
    [GPUImageContext setActiveShaderProgram:self.bgFilterProgram];
//    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //draw bg
    CGFloat heightScaling, widthScaling;
    CGSize textureSize = self.bgFrameBuffer.size;
    CGRect bounds = CGRectMake(0, 0, self.renderSize.width, self.renderSize.height);
    CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(textureSize, bounds);

    widthScaling = self.renderSize.height / insetRect.size.height;
    heightScaling = self.renderSize.width / insetRect.size.width;

    GLfloat normalVertices[] = {
        -1.0f * widthScaling, -1.0f * heightScaling,
        1.0f * widthScaling, -1.0f * heightScaling,
        -1.0f * widthScaling,  1.0f * heightScaling,
        1.0f * widthScaling,  1.0f * heightScaling,
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

- (void)willBeginRender {
    if(self.bUseBackGroundImage && self.bgFrameBuffer) {
        [self drawBackGroundImage];
    }
    [self updateFillType];
    BOOL bAntiAliasing = [self checkRotated];
    CGFloat fWidth = 0.0;
    if(bAntiAliasing){
        fWidth = 2./self.renderSize.width;
    }
    self.vector4ParamValue1 = (GPUVector4){fWidth, 0.0, 0.0, 0.0};
}

- (void)willEndRender {
    
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


- (BOOL)checkRotated {
    CGAffineTransform transrom = CATransform3DGetAffineTransform(self.transform3D);
    CGFloat rotate = atanf(transrom.b/transrom.a);
    CGFloat degree = rotate/M_PI * 180.0 + 0.1;
    int iMode = degree / 90.0;
    if(fabs(degree - iMode * 90.0)< 1.0) {
        //        NSLog(@"checkRotated NO, %f", degree);
        return NO;
    }
    //    NSLog(@"checkRotated YES, %f", degree);
    return YES;
}

@end
