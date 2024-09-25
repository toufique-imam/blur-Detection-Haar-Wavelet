attribute vec4 position;
attribute vec4 inputTextureCoordinate;
attribute vec4 normal;
uniform mat4 modelViewProjMatrix;
uniform mat4 normalTransformMatrix;
uniform mat4 projectMatrix;
uniform float highlight_roi_start_x;
uniform float highlight_roi_start_y;
uniform float highlight_texture_height;
uniform float highlight_texture_width;
uniform float multiply_roi_start_x;
uniform float multiply_roi_start_y;
uniform float multiply_texture_height;
uniform float multiply_texture_width;
varying vec2 highlight_texture_uv;
varying vec2 multiply_texture_uv;
void main(){    
    highlight_texture_uv.x = (inputTextureCoordinate.x * 1080.0 - highlight_roi_start_x) / highlight_texture_width;
    highlight_texture_uv.y = (inputTextureCoordinate.y * 1160.0 - highlight_roi_start_y) / highlight_texture_height;
    multiply_texture_uv.x = (inputTextureCoordinate.x * 1080.0 - multiply_roi_start_x) / multiply_texture_width;
    multiply_texture_uv.y = (inputTextureCoordinate.y * 1160.0 - multiply_roi_start_y) / multiply_texture_height;
    gl_Position = projectMatrix * modelViewProjMatrix * position;
}