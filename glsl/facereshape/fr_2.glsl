precision highp float;

uniform sampler2D input_image_texture;
uniform sampler2D three_dim_pass_texture;
uniform sampler2D lipstick_mask_texture;
uniform float retouch_lip_plumper_fullness;
uniform int half_kernel_size;
uniform float frame_width;
uniform float frame_height;
uniform int rotation;

varying vec2 texture_coordinate;
varying vec2 lipstick_texcoord;

const mat3 RGBToYCbCr = mat3(0.299, -0.169, 0.5, 0.587, -0.331, -0.419, 0.114, 0.5, -0.081);
const mat3 YCbCrToRGB = mat3(1.0000, 1.0000, 1.0000, -0.0009, -0.3437, 1.7721, 1.4017, -0.7142, 0.0001);
vec3 AddShadow(vec3 src_color, float mask_value, float strength, int algorithm_index);
vec3 RGBtoHSV(vec3 c);
vec3 HSVtoRGB(vec3 c);

void main()
{
    if (any(greaterThan(abs(lipstick_texcoord - vec2(0.5)), vec2(0.5))))
    {
        vec4 src_pixel = texture2D(input_image_texture, texture_coordinate);
        float shadow_intensity = retouch_lip_plumper_fullness * 0.006;
        gl_FragColor.rgb = AddShadow(src_pixel.rgb, texture2D(three_dim_pass_texture, texture_coordinate).a, shadow_intensity, 0);
        gl_FragColor.a = 1.0;
        return;
    }
    vec4 src_dst = texture2D(input_image_texture, texture_coordinate);
    float lower_lip_mask = texture2D(lipstick_mask_texture, lipstick_texcoord).a;
    {
        float fullness_for_lighting = min(50.0, retouch_lip_plumper_fullness) * 0.01;
        float specular_lighting_lower = texture2D(three_dim_pass_texture, texture_coordinate).r;
        float shift = 0.3 * (1.0 - specular_lighting_lower);
        float specular_shifted = specular_lighting_lower - shift;
        if (specular_shifted > 0.0)
        {
            float lighting_strength = min(1.0, lower_lip_mask * specular_shifted * fullness_for_lighting * 1.25);
            vec3 ycbcr = RGBToYCbCr * src_dst.rgb;
            float max_dst_y = -1.0417 * pow(ycbcr.r, 3.0) + 0.8482 * pow(ycbcr.r, 2.0) + 1.1935 * ycbcr.r - 0.0036;
            float dst_y = mix(ycbcr.r, max_dst_y, lighting_strength);
            ycbcr.r = clamp(dst_y, 0.0, 1.0);
            src_dst.rgb = YCbCrToRGB * ycbcr;
        }
        else
        {
            float lighting_strength = min(1.0, lower_lip_mask * (-specular_shifted) * fullness_for_lighting * 1.25);
            vec3 ycbcr = RGBToYCbCr * src_dst.rgb;
            float max_dst_y = ycbcr.r * 0.7;
            float dst_y = mix(ycbcr.r, max_dst_y, lighting_strength);
            ycbcr.r = clamp(dst_y, 0.0, 1.0);
            src_dst.rgb = YCbCrToRGB * ycbcr;
        }
    }
    float shadow_intensity = retouch_lip_plumper_fullness * 0.006;
    src_dst.rgb = AddShadow(src_dst.rgb, texture2D(three_dim_pass_texture, texture_coordinate).a, shadow_intensity, 0);
    gl_FragColor = src_dst;
}
vec3 AddShadow(vec3 src_color, float mask_value, float strength, int algorithm_index)
{
    float pixel_y = 0.299 * src_color[0] + 0.587 * src_color[1] + 0.114 * src_color[2];
    float alpha_gradient_ratio = max(0.0, min(0.75, pow(mask_value, 1.5))) * strength;
    float max_shrink_y = pixel_y - (0.3432 * pow(pixel_y, 2.0) + 0.6388 * pixel_y + 0.0031);
    float shrink_y = max_shrink_y * (alpha_gradient_ratio / 0.2275);
    int is_shadow_underflow = 0;
    vec3 dst_pixel;
    for (int c = 0; c < 3; c++)
    {
        if (src_color[c] < shrink_y)
            is_shadow_underflow = 1;
        dst_pixel[c] = max(0.0, src_color[c] - shrink_y);
    }
    if (alpha_gradient_ratio > 0.0 && is_shadow_underflow == 0)
    {
        vec3 hsv = RGBtoHSV(src_color);
        float oldV = hsv[2];
        hsv[2] = max(0.0, hsv[2] - shrink_y);
        float original_ratio = (hsv[2] > 0.0)? oldV / hsv[2] : 1.0;
        float ratio = (hsv[2] > 0.0)? min(1.0, (oldV - hsv[2]) / 0.5) * 1.5 : 0.0;
        float exponent = max(1.0, pow(2.0, max(0.0, (0.2 - hsv[1])) / 0.1) * min(1.0, (oldV - 0.8) / 0.1));
        float oldV_ratio = pow(min(1.0, max(0.0, oldV / 0.3)), 3.0);
        float oldS_ratio = 1.0 - max(0.0, min(1.0, (hsv[1] - 0.1) / 0.4));
        hsv[1] = min(1.0, max(hsv[1] * original_ratio, min(1.0, hsv[1] * (1.0 + ratio * exponent * oldS_ratio) * oldV_ratio)));
        dst_pixel = HSVtoRGB(hsv);
    }
    return dst_pixel;
}
vec3 RGBtoHSV(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 HSVtoRGB(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
