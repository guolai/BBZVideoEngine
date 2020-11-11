//
//  BBZShader.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/28.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZShader.h"
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const kNodeVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kNodeTransformVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform mat4 matParam441;
 uniform mat4 matParam442;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = matParam441 * vec4(position.xy, 1.0, 1.0) * matParam442;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const kNodeYUV420FTransformFragmentShaderString = SHADER_STRING
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

NSString *const kNodePassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

NSString *const kNodeRGBTransformFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D inputImageTexture;

 void main()
 {
     mediump vec4 rgb = texture2D(inputImageTexture, textureCoordinate);

     gl_FragColor = rgb;
 }
 );


NSString *const kNodeFBFectchYUV420FTransformFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform mediump mat3 matParam;
 uniform mediump vec4 v4Param1;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     mediump vec4 bgColor = gl_LastFragData[0];
     yuv.x = texture2D(inputImageTexture, textureCoordinate).r;
     yuv.yz = texture2D(inputImageTexture2, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = matParam * yuv;
     
     highp float width = v4Param1.x;
     if(width > 0.0007) {
         highp vec2 uv = (textureCoordinate - vec2(width, width)) / (1.0 - width * 2.0);
         if(uv.x < 0.0 ) {
             if(uv.y < 0.0) {
                 uv.x = max(abs(uv.x), abs(uv.y));
             } else if(uv.y > 1.0) {
                 uv.x = max(abs(uv.x), abs(uv.y-1.0));
             }
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.x)));
         }else if(uv.x > 1.0) {
             uv.x = abs(uv.x - 1.0);
             if(uv.y < 0.0) {
                 uv.x = max(uv.x, abs(uv.y));
             } else if(uv.y > 1.0) {
                 uv.x = max(uv.x, abs(uv.y-1.0));
             }
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.x)));
         } else if(uv.y < 0.0) {
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.y)));
         } else if(uv.y > 1.0) {
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.y - 1.0)));
         }
     }
     
     gl_FragColor = vec4(rgb, 1.0);
 }
 );

NSString *const kNodeFBFectchRGBTransformFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform mediump vec4 v4Param1;
 
 
 void main()
 {
     mediump vec3 rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     mediump vec4 bgColor = gl_LastFragData[0];
     
     highp float width = v4Param1.x;
     if(width > 0.0007) {
         highp vec2 uv = (textureCoordinate - vec2(width, width)) / (1.0 - width * 2.0);
         if(uv.x < 0.0 ) {
             if(uv.y < 0.0) {
                 uv.x = max(abs(uv.x), abs(uv.y));
             } else if(uv.y > 1.0) {
                 uv.x = max(abs(uv.x), abs(uv.y-1.0));
             }
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.x)));
         }else if(uv.x > 1.0) {
             uv.x = abs(uv.x - 1.0);
             if(uv.y < 0.0) {
                 uv.x = max(uv.x, abs(uv.y));
             } else if(uv.y > 1.0) {
                 uv.x = max(uv.x, abs(uv.y-1.0));
             }
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.x)));
         } else if(uv.y < 0.0) {
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.y)));
         } else if(uv.y > 1.0) {
             rgb = mix(rgb, bgColor.rgb, smoothstep(0.0, width, abs(uv.y - 1.0)));
         }
     }
     
     gl_FragColor = vec4(rgb, 1.0);
 }
 );


NSString *const kNodeMaskBlendFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform vec4 v4Param1;
 
 vec4 blendColor(in highp vec4 dstColor, in highp vec4 srcColor)
 {
     vec3 vOne = vec3(1.0, 1.0, 1.0);
     vec3 vZero = vec3(0.0, 0.0, 0.0);
     vec3 resultFore = srcColor.rgb + dstColor.rgb * (1.0 - srcColor.a);
     return vec4(resultFore.rgb, 1.0);
 }
 
 void main()
 {
     vec4 bgColor = texture2D(inputImageTexture, textureCoordinate);
     vec2 maskSize = v4Param1.zw;
     vec2 maskPostion = v4Param1.xy;
     float width = maskSize.x;
     float height = maskSize.y;
     if(textureCoordinate.x > maskPostion.x && textureCoordinate.x < maskPostion.x + width && textureCoordinate.y > maskPostion.y && textureCoordinate.y < maskPostion.y + height) {
         vec2 uv = textureCoordinate - vec2(maskPostion.x,maskPostion.y);
         vec4 srcColor = texture2D(inputImageTexture2, vec2(uv.x / width , uv.y / height));
         bgColor = blendColor(bgColor, srcColor);
     }
     gl_FragColor = bgColor;
 }
 );


NSString *const kNodeMaskBlendVideoFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform vec4 v4Param1;
 
 vec4 blendColor(in vec4 dstColor, in vec4 srcColor)
 {
    vec3 vOne = vec3(1.0, 1.0, 1.0);
    vec3 vZero = vec3(0.0, 0.0, 0.0);
    vec3 resultFore = vOne - (vOne - dstColor.rgb) * (vOne - srcColor.rgb);
    vec4 resultColor = vec4(resultFore, min(srcColor.a+dstColor.a, 1.0));
    return resultColor;
}
 
 void main()
 {
    float wScale = 1.0;
    float hScale = 1.0;
    lowp vec4 c1 = texture2D(inputImageTexture, textureCoordinate);
    vec2 coord = vec2((textureCoordinate.x-0.5)*(1.0/wScale)+0.5,(textureCoordinate.y-0.5)*(1.0/hScale)+0.5);
    if (coord.x>=0.0&&coord.x<=1.0&&coord.y>=0.0&&coord.y<=1.0)
    {
        lowp vec4 c2 = texture2D(inputImageTexture2, coord);
        gl_FragColor = blendColor(c1,c2);
    }
    else
    {
        gl_FragColor = c1;
    }
}
 );


NSString *const kNodeMaskBlendLRVideoFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform vec4 v4Param1;
 
 vec4 blendColor(in highp vec4 dstColor, in highp vec4 srcColor)
 {
    vec3 vOne = vec3(1.0, 1.0, 1.0);
    vec3 vZero = vec3(0.0, 0.0, 0.0);
    vec3 resultFore = srcColor.rgb + dstColor.rgb * (1.0 - srcColor.a);
    return vec4(resultFore.rgb, 1.0);
}
 
 void main()
 {
    float wScale = 1.0;
    float hScale = 1.0;
    lowp vec4 c1 = texture2D(inputImageTexture, textureCoordinate);
    vec2 coord = vec2((textureCoordinate.x-0.5)*(1.0/wScale)+0.5,(textureCoordinate.y-0.5)*(1.0/hScale)+0.5);
    if (coord.x>=0.0&&coord.x<=1.0&&coord.y>=0.0&&coord.y<=1.0)
    {
        lowp vec4 c2 = texture2D(inputImageTexture2, vec2(coord.x * 0.5, coord.y));
        lowp vec4 c3 = texture2D(inputImageTexture2, vec2(coord.x * 0.5 + 0.5, coord.y));
        gl_FragColor = blendColor(c1, vec4(c2.rgb,c3.r));
    }
    else
    {
        gl_FragColor = c1;
    }
}
 );



NSString *const kNodeLutFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform vec4 v4Param1;
 
 vec4 lut(vec4 textureColor, sampler2D lutSampler)
 {
    highp float blueColor = textureColor.b * 63.0;
    float intensity = v4Param1.x;
    highp vec2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    
    highp vec2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos1.y = (quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
    
    highp vec2 texPos2;
    texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
    texPos2.y = (quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g);
    
    lowp vec4 newColor1 = texture2D(lutSampler, texPos1);
    lowp vec4 newColor2 = texture2D(lutSampler, texPos2);
    
    lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
    vec4 retColor = mix(textureColor, vec4(newColor.rgb, textureColor.w), intensity);
    return retColor;
}
 void main()
{
    vec4 sourceColor = texture2D(inputImageTexture, textureCoordinate);
    sourceColor = lut(sourceColor, inputImageTexture2);
    gl_FragColor = sourceColor;
    
}
 );



NSString *const kNodeMovieEndingFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform vec4 v4Param1;
 
 void main()
 {
    float progress = v4Param1.x;
    lowp vec4 c1 = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 vZero = vec4(0.0, 0.0, 0.0, 1.0);
    gl_FragColor = mix(c1, vZero, progress);
  
}
 );



@implementation BBZShader

+ (NSString *)vertextShader {
    return kNodeVertexShaderString;
}

+ (NSString *)vertextTransfromShader {
    /*
     matParam441 : transformMatrix
     matParam442 : orthographicMatrix
     */
    return kNodeTransformVertexShaderString;
}

+ (NSString *)fragmentPassthroughShader {
    return  kNodePassthroughFragmentShaderString;
}


+ (NSString *)fragmentYUV420FTransfromShader {
    return  kNodeYUV420FTransformFragmentShaderString;
}

+ (NSString *)fragmentRGBTransfromShader {
    return  kNodeRGBTransformFragmentShaderString;
}

+ (NSString *)fragmentFBFectchYUV420FTransfromShader {
    /*
     matParam : yuvConversionMatrix
     v4Param1 : x:羽化参数
     */
    NSString *fragmentShaderToUse = [NSString stringWithFormat:@"#extension GL_EXT_shader_framebuffer_fetch : require\n %@",kNodeFBFectchYUV420FTransformFragmentShaderString];
    return fragmentShaderToUse;
}

+ (NSString *)fragmentFBFectchRGBTransfromShader {
    /*
     v4Param1 : x:羽化参数
     */
    NSString *fragmentShaderToUse = [NSString stringWithFormat:@"#extension GL_EXT_shader_framebuffer_fetch : require\n %@",kNodeFBFectchRGBTransformFragmentShaderString];
    return fragmentShaderToUse;
}


+ (NSString *)fragmentMaskBlendShader {
    /*
     v4Param1 : maskPostion,maskSize
     */
     return  kNodeMaskBlendFragmentShaderString;
}

+ (NSString *)fragmentMaskBlendVideoShader {
    /*
     v4Param1 : wScale,hScale
     */
    return  kNodeMaskBlendVideoFragmentShaderString;
}

+ (NSString *)fragmentMaskBlendLeftRightVideoShader {
    /*
     v4Param1 : wScale,hScale
     */
    return  kNodeMaskBlendLRVideoFragmentShaderString;
}

+ (NSString *)fragmentLutShader {
    /*
     v4Param1 : x:lut程度
     */
    return  kNodeLutFragmentShaderString;
}

+ (NSString *)fragmentMovieEndingShader {
    /*
     v4Param1 : progress
     */
    return  kNodeMovieEndingFragmentShaderString;
}

@end
