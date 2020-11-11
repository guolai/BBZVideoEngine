#extension GL_OES_standard_derivatives : enable
precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform mediump vec4 v4Param1;

float progress = v4Param1.x;

void main()
{
    vec4 color1 = texture2D(inputImageTexture, textureCoordinate);
    vec4 color2 = texture2D(inputImageTexture2, textureCoordinate);
    gl_FragColor = mix(color1, color2, step(1.0-textureCoordinate.x,progress));
}
