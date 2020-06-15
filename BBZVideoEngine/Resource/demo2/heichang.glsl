#extension GL_OES_standard_derivatives : enable
precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform mediump vec4 v4Param1;



vec4 blendColor(in vec4 dstColor, in vec4 srcColor, in float alpha)
{
    vec3 resultFore = dstColor.rgb * (1.0 - alpha) + srcColor.rgb * alpha;
    vec4 resultColor = vec4(resultFore, 1.0);
    return resultColor;
}

void main()
{
    highp vec2 coordinate = textureCoordinate;
    lowp vec4 outputColor;
    vec4 vZero = vec4(0.0, 0.0, 0.0, 1.0);

    float State = v4Param1.y;
    float FrontAlpha = v4Param1.x;
    float EndAlpha = v4Param1.z;
    
    if(State < 1.0)
    {
        highp vec4 v1 = texture2D(inputImageTexture, coordinate);
        outputColor = blendColor(vZero, v1, FrontAlpha);
    }
    else
    {
        if(State < 2.0)
        {
            outputColor =vZero;
        }
        else
        {
            highp vec4 v1 = texture2D(inputImageTexture2, coordinate);
            outputColor = blendColor(vZero, v1, EndAlpha);
        }
    }
    gl_FragColor = outputColor;
}
