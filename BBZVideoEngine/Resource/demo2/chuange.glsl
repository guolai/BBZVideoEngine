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

vec4 transition (vec2 uv) {
    float progress = v4Param1.x;
    float t = progress;
    
    if (mod(floor(uv.y*100.*progress),2.)==0.)
        t*=2.-.5;
    
    return mix(
               getFromColor(uv),
               getToColor(uv),
               mix(t, progress, smoothstep(0.8, 1.0, progress))
               );
}
void main()
{
    gl_FragColor = transition(textureCoordinate);
}
