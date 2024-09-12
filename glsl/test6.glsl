precision highp float;
uniform sampler2D input_image_texture;
uniform sampler2D morph_2nd_pass_texture;
uniform sampler2D lipstick_mask_texture;
uniform int half_kernel_size;
uniform float frame_height;
uniform int rotation;
uniform float retouch_lip_plumper_wrinkless;
varying vec2 texcoord;
varying vec2 lipstick_texcoord;
void main()
{
    if (any(greaterThan(abs(lipstick_texcoord - vec2(0.5)), vec2(0.5))))
    {
        gl_FragColor = texture2D(input_image_texture, texcoord);
        return;
    }
    vec4 src_dst = texture2D(input_image_texture, texcoord);
    vec3 smoothed_morph = vec3(0.0);
    {
        float sample_step = 1.0 / frame_height;
        for (int k = -half_kernel_size; k <= half_kernel_size; k++)
        {
            vec2 sample_shift = (rotation == 0 || rotation == 180)? vec2(float(k) * sample_step, 0.0) : vec2(0.0, float(k) * sample_step);
            smoothed_morph += texture2D(morph_2nd_pass_texture, texcoord + sample_shift).rgb;
        }
        smoothed_morph /= float(half_kernel_size * 2 + 1);
        float src_y = 0.299 * src_dst.r + 0.587 * src_dst.g + 0.114 * src_dst.b;
        float result_y = 0.299 * smoothed_morph.r + 0.587 * smoothed_morph.g + 0.114 * smoothed_morph.b;
        float diff_y = abs(result_y - src_y);
        float threshold = 0.02;
        if (diff_y < threshold)
            smoothed_morph = src_dst.rgb;
    }
    float protection_mask = texture2D(lipstick_mask_texture, lipstick_texcoord).r;
    src_dst.rgb = mix(src_dst.rgb, smoothed_morph, protection_mask * retouch_lip_plumper_wrinkless * 0.01);
    gl_FragColor = vec4(src_dst.rgb, 1.0);
}
