precision mediump float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D exposure_table;
uniform int positive_exposure;
const float base_value = 0.01;
const float ratio_range = 1.35;
void main() {
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    vec3 src_color = textureColor.rgb;
    vec3 dst_color = src_color;
    vec2 table_coordinate = vec2((src_color.r * 255.0 + 0.5) / 256.0, 0.5);
    dst_color.r = texture2D(exposure_table, table_coordinate).a;
    table_coordinate.x = (src_color.g * 255.0 + 0.5) / 256.0;
    dst_color.g = texture2D(exposure_table, table_coordinate).a;
    table_coordinate.x = (src_color.b * 255.0 + 0.5) / 256.0;
    dst_color.b = texture2D(exposure_table, table_coordinate).a;
    if (positive_exposure == 1) {
        vec3 color_ratio = (dst_color + base_value) / (src_color + base_value);
        float max_ratio = min(min(color_ratio.r, color_ratio.g), color_ratio.b) * ratio_range;
        color_ratio = min(color_ratio, vec3(max_ratio));
        vec3 dst_color2 = (src_color + base_value) * color_ratio - base_value;
        dst_color = (dst_color + dst_color2) * 0.5;
    }
    gl_FragColor = vec4(dst_color, textureColor.a);
}