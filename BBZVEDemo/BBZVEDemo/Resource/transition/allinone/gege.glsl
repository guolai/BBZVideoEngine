#extension GL_OES_standard_derivatives : enable
precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform mediump vec4 v4Param1;


vec4 getFromColor(vec2 p)
{
    return texture2D(inputImageTexture, p);
}

vec4 getToColor(vec2 p)
{
    return texture2D(inputImageTexture2, p);
}

vec2 size = vec2(10.0, 10.0);
float smoothness = 0.5;

float rand (vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 transition(vec2 p) {
    float progress = v4Param1.x;
    float r = rand(floor(vec2(size) * p));
    float m = smoothstep(0.0, -smoothness, r - (progress * (1.0 + smoothness)));
    return mix(getFromColor(p), getToColor(p), m);
}
void main()
{
    gl_FragColor = transition(textureCoordinate);
}
