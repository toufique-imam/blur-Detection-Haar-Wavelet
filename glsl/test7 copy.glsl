
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
varying vec2 textureCoordinate;
varying vec2 lipstick_texture_coordinate;
uniform sampler2D inputImageTexture;
uniform sampler2D lipstick_texture;
uniform sampler2D lipstick_layer_texture;

uniform sampler2D blend_weight_and_level_map_texture;
uniform vec3 lipstick_color_0;
uniform vec3 lipstick_color_1;
uniform int lipstick_layer_count;
uniform int lipstick_is_upper_lower_omber;
uniform float gloss_contrast_scale;
uniform float gloss_contrast_shift;
uniform float gloss_contrast_shrink;
uniform float force_bright_threshold;
uniform int enable_lipstick;

const lowp float flt_epsilon = 0.001;
vec3 RGBtoHCV(vec3 rgb) {
    vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1.0, 0.66666667) : vec4(rgb.gb, 0.0, -0.33333333);
    vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
    float c = q.x - min(q.w, q.y);
    float h = abs((q.w - q.y) / (6.0 * c + flt_epsilon) + q.z);
    return vec3(h, c, q.x);
}
vec3 RGBtoHSL(vec3 rgb) {
    vec3 hcv = RGBtoHCV(rgb);
    float l = hcv.z - hcv.y * 0.5;
    float s = hcv.y / (1.0 - abs(l * 2.0 - 1.0) + flt_epsilon);
    return vec3(hcv.x, s, l);
}
vec3 HSLtoRGB(vec3 hsl) {
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
float HardLight(float color, float layer) {
    if (color < 0.5) {
        color = 2.0 * layer * color;
    } else {
        color = 1.0 - 2.0 * (1.0 - layer) * (1.0 - color);
    }
    return color;
}
void main() {
    vec3 source = texture2D(inputImageTexture, textureCoordinate).rgb;
    if (any(greaterThan(abs(lipstick_texture_coordinate - vec2(0.5)), vec2(0.5)))) {
        gl_FragColor = vec4(source, 1.0);
        return;
    } else {
        gl_FragColor = texture2D(lipstick_texture, textureCoordinate).b;
        return;
    
        vec3 dst_color = source;
        float alpha = texture2D(lipstick_texture, lipstick_texture_coordinate).r * float(enable_lipstick);
        float contrast_mask = texture2D(lipstick_texture, lipstick_texture_coordinate).g * alpha;
        float gloss = texture2D(lipstick_texture, lipstick_texture_coordinate).b * float(enable_lipstick);
        float gray = 0.299 * source.r + 0.587 * source.g + 0.114 * source.b;
        float contrast = max(min((gray * gloss_contrast_scale + gloss_contrast_shift) * contrast_mask + 0.5 * (1.0 - contrast_mask), 1.0), 0.0);
        if (contrast < 0.5)
            contrast = 0.5 - (0.5 - contrast) * gloss_contrast_shrink;
        // if (use_median > 0.5) {
        //     gray = texture2D(lipstick_median_texture, lipstick_texture_coordinate).r;
        // }
        float alpha_0 = texture2D(lipstick_layer_texture, lipstick_texture_coordinate).r;
        float alpha_1 = texture2D(lipstick_layer_texture, lipstick_texture_coordinate).g;
        float blend_weight = texture2D(blend_weight_and_level_map_texture, vec2(gray, 0)).r;
        float level_weight_0 = texture2D(blend_weight_and_level_map_texture, vec2(gray, 0)).g;
        float level_weight_1 = texture2D(blend_weight_and_level_map_texture, vec2(gray, 0)).b;
        if (lipstick_layer_count == 1) {
            float level_weight = level_weight_0 * alpha;
            vec3 color = mix(lipstick_color_0 * source, lipstick_color_0, blend_weight);
            dst_color = mix(source, color, level_weight);
        } else if (lipstick_layer_count == 2) {
            if (lipstick_is_upper_lower_omber == 0) { 
                float level_weight = mix(level_weight_1, level_weight_0, alpha_0) * alpha;
                vec3 color = mix(lipstick_color_1, lipstick_color_0, alpha_0);
                color = mix(color * source, color, blend_weight);
                dst_color = mix(source, color, level_weight);
            } else if (lipstick_is_upper_lower_omber == 1) {
                float tmp = alpha_0;
                alpha_0 = alpha_0 * (1.0 - alpha_1);
                alpha_1 = alpha_1 * (1.0 - tmp);
                float alpha_sum = alpha_0 + alpha_1;
                if (alpha_sum > 0.0) {
                    alpha_0 = alpha_0 / alpha_sum;
                    alpha_1 = alpha_1 / alpha_sum;
                } else {
                    alpha_0 = alpha_1 = 0.0;
                }
                float level_weight = (alpha_0 * level_weight_0 + alpha_1 * level_weight_1) * alpha;
                vec3 color = lipstick_color_0 * alpha_0 + lipstick_color_1 * alpha_1;
                color = mix(color * source, color, blend_weight);
                dst_color = mix(source, color, level_weight);
            }
        }
        float diff = max(gray - force_bright_threshold, 0.0) * alpha;
        dst_color = vec3(1.0) - (vec3(1.0) - dst_color) * vec3(1.0 - diff);
        dst_color.r = HardLight(dst_color.r, contrast);
        dst_color.g = HardLight(dst_color.g, contrast);
        dst_color.b = HardLight(dst_color.b, contrast);
        dst_color = vec3(1.0) - (vec3(1.0) - dst_color) * vec3(1.0 - gloss);
        float transition_ratio = (min(max(abs(lipstick_texture_coordinate.x - 0.5), 0.083), 0.5) - 0.083) / 0.417;
        // float luma_weight = gray * shimmer_normalize_factor;
        // float shimmer_weight = 1.0 - 0.3 * transition_ratio;
        // float shimmer = texture2D(lipstick_shimmer_texture, lipstick_texture_coordinate).r * alpha;
        // vec3 hsl = RGBtoHSL(dst_color);
        // hsl.z = min(hsl.z + shimmer * shimmer_weight * luma_weight * alpha, 1.0);
        // dst_color = HSLtoRGB(hsl);
        // if (enable_color_shimmer > 0) {
        //     float contrast_weight = max(min(gray * 0.5 + 0.25, 0.75), 0.25);
        //     float color_weight = max(min(shimmer * 2.5 * alpha * shimmer_weight * contrast_weight * shimmer_intensity, 0.8), 0.0);
        //     dst_color = mix(dst_color, shimmer_color, color_weight);
        // }
        gl_FragColor = vec4(dst_color, 1.0);
    }
}