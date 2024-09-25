
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;

#else
precision mediump float;

#endif
varying vec2 highlight_texture_uv;
varying vec2 multiply_texture_uv;
uniform sampler2D highlight_shimmer_texture;
uniform sampler2D highlight_texture;
uniform sampler2D multiply_texture;
void main(){    
    float highlight_alpha = texture2D(highlight_texture, highlight_texture_uv).a;
    float shimmer_alpha = texture2D(highlight_shimmer_texture, highlight_texture_uv).a;
    float multiply_alpha = texture2D(multiply_texture, multiply_texture_uv).a;
    gl_FragColor = vec4(1.0);
}