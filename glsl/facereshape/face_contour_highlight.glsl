
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;

#else
precision mediump float;

#endif
varying vec2 textureCoordinate;
varying vec2 textureCoordinate2;
varying vec2 skin_mask_coordinate;
varying vec2 skin_rotated_coordinate;
uniform float dynamic_range_start;
uniform float dynamic_range_end;
uniform float frame_buffer_height;
uniform float frame_buffer_width;
uniform vec3 highlight_color;
uniform sampler2D highlight_glow_map;
uniform float highlight_intensity;
uniform float highlight_shimmer_intensity;
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform vec3 multiply_color;
uniform float multiply_intensity;
uniform float contour_multiply_weight;
uniform sampler2D skin_forehead_neck_mask;
uniform sampler2D skin_base_map;
uniform float skin_forehead_boundary;
uniform float step_3D_x;
uniform float step_3D_y;
vec3 AddHighlight(vec3 src_color, vec3 highlight_color, float highlight_alpha, float highlight_glow_value, float shimmer_alpha, float shimmer_intensity);
vec3 AddHighlightShimmer(float shimmer_intensity, float skin_alpha, float shimmer_alpha, float dominant_skin_y, float highlight_alpha, float shimmer_weight, float dynamic_range_start, float dynamic_range_end, vec3 src_color, vec3 blend_0, vec3 blend_1);
vec3 AddMultiply(vec3 src_color, vec3 multiply_color, float multiply_alpha);
vec3 AddNormalBlend(vec3 src_color, vec3 top_color, float alpha);
vec3 HSL2RGB(vec3 hsl);
vec3 RGB2HCV(vec3 rgb);
vec3 RGB2HSL(vec3 rgb);
const float FLT_EPSILON = 0.001;
const float LIGHT_ANGLE_LOWER_BOUND = 0.8;
const float DISTRIBUTION_OFFSET = 13.0 / 255.0;
const float SHIMMER_DECAY_RANGE = 0.6;
const float SHIMMER_BRIGHT_FACTOR = 100.0 / 28.0;
const float SHIMMER_SKIN_WEIGHT = 0.8;
const float SHIMMER_TEXTURE_WEIGHT = 1.0 - SHIMMER_SKIN_WEIGHT;
void main() {
    float skin_base_map_value = texture2D(skin_base_map, skin_mask_coordinate).a;
    float face_edge_smooth_strength = 1.0 - 2.0 * abs(skin_base_map_value - 0.5);
    vec3 root_rgb = texture2D(inputImageTexture2, textureCoordinate2).rgb;
    float root_gray_value = root_rgb.b * .114 + root_rgb.g * .587 + root_rgb.r * .299;
    float highlight_alpha = texture2D(inputImageTexture, textureCoordinate).r;
    float shimmer_alpha = texture2D(inputImageTexture, textureCoordinate).g;
    float multiply_alpha = texture2D(inputImageTexture, textureCoordinate).b;
    if (face_edge_smooth_strength > 0.0) {
        vec4 sample_00 = texture2D(inputImageTexture, textureCoordinate + vec2(-1.5 / frame_buffer_width, -4.5 / frame_buffer_height));
        vec4 sample_01 = texture2D(inputImageTexture, textureCoordinate + vec2(0.5 / frame_buffer_width, -4.5 / frame_buffer_height));
        vec4 sample_02 = texture2D(inputImageTexture, textureCoordinate + vec2(2.5 / frame_buffer_width, -3.5 / frame_buffer_height));
        vec4 sample_03 = texture2D(inputImageTexture, textureCoordinate + vec2(-3.5 / frame_buffer_width, -2.5 / frame_buffer_height));
        vec4 sample_04 = texture2D(inputImageTexture, textureCoordinate + vec2(-1.5 / frame_buffer_width, -2.5 / frame_buffer_height));
        vec4 sample_05 = texture2D(inputImageTexture, textureCoordinate + vec2(0.5 / frame_buffer_width, -2.5 / frame_buffer_height));
        vec4 sample_06 = texture2D(inputImageTexture, textureCoordinate + vec2(2.5 / frame_buffer_width, -1.5 / frame_buffer_height));
        vec4 sample_07 = texture2D(inputImageTexture, textureCoordinate + vec2(4.5 / frame_buffer_width, -1.5 / frame_buffer_height));
        vec4 sample_08 = texture2D(inputImageTexture, textureCoordinate + vec2(-4.5 / frame_buffer_width, -0.5 / frame_buffer_height));
        vec4 sample_09 = texture2D(inputImageTexture, textureCoordinate + vec2(-2.5 / frame_buffer_width, -0.5 / frame_buffer_height));
        vec4 sample_10 = texture2D(inputImageTexture, textureCoordinate + vec2(-0.5 / frame_buffer_width, -0.5 / frame_buffer_height));
        vec4 sample_11 = texture2D(inputImageTexture, textureCoordinate + vec2(0.5 / frame_buffer_width, -0.5 / frame_buffer_height));
        vec4 sample_12 = texture2D(inputImageTexture, textureCoordinate + vec2(-0.5 / frame_buffer_width, 0.5 / frame_buffer_height));
        vec4 sample_13 = texture2D(inputImageTexture, textureCoordinate + vec2(0.5 / frame_buffer_width, 0.5 / frame_buffer_height));
        vec4 sample_14 = texture2D(inputImageTexture, textureCoordinate + vec2(2.5 / frame_buffer_width, 0.5 / frame_buffer_height));
        vec4 sample_15 = texture2D(inputImageTexture, textureCoordinate + vec2(4.5 / frame_buffer_width, 0.5 / frame_buffer_height));
        vec4 sample_16 = texture2D(inputImageTexture, textureCoordinate + vec2(-4.5 / frame_buffer_width, 1.5 / frame_buffer_height));
        vec4 sample_17 = texture2D(inputImageTexture, textureCoordinate + vec2(-2.5 / frame_buffer_width, 1.5 / frame_buffer_height));
        vec4 sample_18 = texture2D(inputImageTexture, textureCoordinate + vec2(-0.5 / frame_buffer_width, 2.5 / frame_buffer_height));
        vec4 sample_19 = texture2D(inputImageTexture, textureCoordinate + vec2(1.5 / frame_buffer_width, 2.5 / frame_buffer_height));
        vec4 sample_20 = texture2D(inputImageTexture, textureCoordinate + vec2(3.5 / frame_buffer_width, 2.5 / frame_buffer_height));
        vec4 sample_21 = texture2D(inputImageTexture, textureCoordinate + vec2(-2.5 / frame_buffer_width, 3.5 / frame_buffer_height));
        vec4 sample_22 = texture2D(inputImageTexture, textureCoordinate + vec2(-0.5 / frame_buffer_width, 4.5 / frame_buffer_height));
        vec4 sample_23 = texture2D(inputImageTexture, textureCoordinate + vec2(1.5 / frame_buffer_width, 4.5 / frame_buffer_height));
        vec4 smoothed_alpha = (sample_00 + sample_01 + sample_02 + sample_03 + sample_04 + sample_05 + sample_06 + sample_07 + sample_08 + sample_09 + sample_10 + sample_11 + sample_12 + sample_13 + sample_14 + sample_15 + sample_16 + sample_17 + sample_18 + sample_19 + sample_20 + sample_21 + sample_22 + sample_23) / 24.0;
        multiply_alpha = mix(multiply_alpha, smoothed_alpha.b, face_edge_smooth_strength);
        highlight_alpha = mix(highlight_alpha, smoothed_alpha.r, face_edge_smooth_strength);
        shimmer_alpha = mix(shimmer_alpha, smoothed_alpha.g, face_edge_smooth_strength);
    }

    vec3 highlight_color_adjust = highlight_color * (dynamic_range_end - dynamic_range_start) + vec3(dynamic_range_start * highlight_alpha);
    float highlight_glow_value = texture2D(highlight_glow_map, vec2(root_gray_value, .5)).a * highlight_alpha;
    highlight_alpha *= highlight_intensity;
    vec3 multiply_color_adjust = multiply_color * (dynamic_range_end - dynamic_range_start) + vec3(dynamic_range_start * multiply_alpha);
    multiply_alpha *= multiply_intensity;

    vec3 result_color = AddHighlight(root_rgb, highlight_color_adjust, highlight_alpha, highlight_glow_value, shimmer_alpha, highlight_shimmer_intensity);
    result_color = mix(AddNormalBlend(result_color, multiply_color_adjust, multiply_alpha), AddMultiply(result_color, multiply_color_adjust, multiply_alpha), contour_multiply_weight);
    float forehead_neck_prob = texture2D(skin_forehead_neck_mask, skin_mask_coordinate).a;
    float to_forehead_distance = skin_forehead_boundary - skin_rotated_coordinate.y;
    float base_blend_factor = 1.0;
    if (to_forehead_distance > 0.1) {
        base_blend_factor = forehead_neck_prob;
    } else if (to_forehead_distance > 0.0) {
        base_blend_factor = mix(base_blend_factor, forehead_neck_prob, to_forehead_distance / 0.1);
    }
    result_color = root_rgb * (1.0 - base_blend_factor) + result_color * base_blend_factor;
    gl_FragColor = vec4(result_color, 1.0);
}
vec3 AddHighlight(vec3 src_color, vec3 highlight_color, float highlight_alpha, float highlight_glow_value, float shimmer_alpha, float shimmer_intensity) {
    vec3 blend_0;
    for (int c = 0; c < 3; c++) {
        if (highlight_color[c] < 0.5) {
            blend_0[c] = 2.0 * src_color[c] * highlight_color[c];
        } else {
            blend_0[c] = 1.0 - 2.0 * (1.0 - src_color[c]) * (1.0 - highlight_color[c]);
        }
    }
    vec3 blend_1 = min(vec3(1.0), mix(src_color + highlight_glow_value, blend_0, highlight_alpha));
    if (shimmer_intensity == 0.0) {
        return blend_1;
    }
    return AddHighlightShimmer(shimmer_intensity, 0.3, shimmer_alpha, 0.719, highlight_alpha, 1.0, dynamic_range_start, dynamic_range_end, src_color, blend_0, blend_1);
}
vec3 AddHighlightShimmer(float shimmer_intensity, float skin_alpha, float shimmer_alpha, float skin_average_y, float highlight_alpha, float shimmer_weight, float dynamic_range_start, float dynamic_range_end, vec3 src_color, vec3 blend_0, vec3 blend_1) {
    float skin_y = clamp(skin_average_y, 0.3, 0.8);
    float shimmer_skin_dependent_l_adjustment_parameter = 2.5 + (0.8 - skin_y);
    float shimmer_background_alpha = 1.0 - dynamic_range_end * shimmer_intensity * highlight_alpha;
    float bright_background_alpha = 1.0 - dynamic_range_end * shimmer_intensity * highlight_alpha;
    vec3 hsl_blend = RGB2HSL(blend_0);
    vec3 hsl_ori = RGB2HSL(src_color);
    vec3 hsl = RGB2HSL(blend_1);
    {
        float normal_l = 255.0 * hsl_ori[2];
        float bright_foreground_weight = pow(1.0 - bright_background_alpha, 3.0);
        float bright_difference = pow(skin_alpha * 1.0851, 3.0);
        bright_difference = (1.0 - hsl[2]) * bright_difference * normal_l * SHIMMER_BRIGHT_FACTOR * bright_foreground_weight;
        float shimmer_difference = normal_l * (1.0 - hsl[2]) * (shimmer_alpha - DISTRIBUTION_OFFSET) * 1.0851 * (1.0 - shimmer_background_alpha);
        shimmer_difference = shimmer_difference * shimmer_weight * 0.1;
        float final_difference = (bright_difference * SHIMMER_SKIN_WEIGHT + shimmer_difference * SHIMMER_TEXTURE_WEIGHT);
        final_difference *= (dynamic_range_end - dynamic_range_start);
        final_difference *= (1.0 + (1.0 - shimmer_intensity) / 0.75) * shimmer_skin_dependent_l_adjustment_parameter;
        hsl[2] = max(hsl[2], min(dynamic_range_end, hsl[2] + 1.0 * final_difference));
        if (hsl[1] > hsl_blend[1]) {
            float s_weight = min(1.0, final_difference * 1.5 * (1.0 - hsl_blend[2]));
            hsl[1] = hsl[1] - s_weight * (hsl[1] - hsl_blend[1]);
        }
    }
    return HSL2RGB(hsl);
}
vec3 AddMultiply(vec3 src_color, vec3 multiply_color, float multiply_alpha) {
    return mix(src_color, src_color * multiply_color, multiply_alpha);
}
vec3 AddNormalBlend(vec3 src_color, vec3 top_color, float alpha) {
    return mix(src_color, top_color, alpha);
}
vec3 HSL2RGB(vec3 hsl) {
    vec3 rgb;
    float x = hsl.x * 6.0;
    rgb.r = abs(x - 3.0) - 1.0;
    rgb.g = 2.0 - abs(x - 2.0);
    rgb.b = 2.0 - abs(x - 4.0);
    rgb = clamp(rgb, 0.0, 1.0);
    float c = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
    rgb = clamp((rgb - vec3(0.5)) * vec3(c) + vec3(hsl.z), 0.0, 1.0);
    return rgb;
}
vec3 RGB2HCV(vec3 rgb) {
    vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1.0, 0.66666667) : vec4(rgb.gb, 0.0, -0.33333333);
    vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
    float c = q.x - min(q.w, q.y);
    float h = abs((q.w - q.y) / (6.0 * c + FLT_EPSILON) + q.z);
    return vec3(h, c, q.x);
}
vec3 RGB2HSL(vec3 rgb) {
    vec3 hcv = RGB2HCV(rgb);
    float l = hcv.z - hcv.y * 0.5;
    float s = hcv.y / (1.0 - abs(l * 2.0 - 1.0) + FLT_EPSILON);
    return vec3(hcv.x, s, l);
}