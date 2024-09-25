attribute vec4 position;
attribute vec4 inputTextureCoordinate;
attribute vec4 inputTextureCoordinate2;
attribute vec4 inputSkinToneMaskCoordinate;
varying vec2 textureCoordinate;
varying vec2 textureCoordinate2;
varying vec2 skin_mask_coordinate;
varying vec2 skin_rotated_coordinate;
uniform vec4 skin_mask_roi;
uniform vec2 skin_region_roi_rect_rotated_cos_sin;
uniform vec2 skin_region_roi_width_height_resized_ratio;

void main(){    
    gl_Position = position;
    textureCoordinate = inputTextureCoordinate.xy;
    textureCoordinate2 = inputTextureCoordinate2.xy;
    vec2 skin_mask_texture_coordinate = inputSkinToneMaskCoordinate.xy;
    vec2 resized_skin_region_coordinate = skin_mask_texture_coordinate.xy * skin_region_roi_width_height_resized_ratio;
    skin_rotated_coordinate.x = dot(resized_skin_region_coordinate, vec2(skin_region_roi_rect_rotated_cos_sin.x, -skin_region_roi_rect_rotated_cos_sin.y));
    skin_rotated_coordinate.y = dot(resized_skin_region_coordinate, skin_region_roi_rect_rotated_cos_sin.yx);
    skin_mask_coordinate.xy = (skin_mask_texture_coordinate.xy - skin_mask_roi.xy) / (skin_mask_roi.zw - skin_mask_roi.xy);
}