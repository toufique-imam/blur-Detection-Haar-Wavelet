precision highp float;
uniform sampler2D input_image_texture;
uniform sampler2D morph_1st_pass_texture;
uniform int half_kernel_size;
uniform float frame_width;
uniform int rotation;
varying vec2 texcoord;
varying vec2 lipstick_texcoord;
const mat3 RGBToYCbCr = mat3(0.299, -0.169, 0.5, 0.587, -0.331, -0.419, 0.114, 0.5, -0.081);
const mat3 YCbCrToRGB = mat3(1.0000, 1.0000, 1.0000, -0.0009, -0.3437, 1.7721, 1.4017, -0.7142, 0.0001);
int ToCPUPixel(float gpu_value);
void main()
{
    if (any(greaterThan(abs(lipstick_texcoord - vec2(0.5)), vec2(0.5))))
    {
        gl_FragColor = vec4(1.0);
        return;
    }
    float sample_step = 1.0 / frame_width;
    float max_of_y = 0.0;
    float min_of_y = 5566.0;
    float avg_of_cb = 0.0;
    float avg_of_cr = 0.0;
    for (int k = -half_kernel_size; k <= half_kernel_size; k++)
    {
        vec2 sample_shift = (rotation == 0 || rotation == 180)? vec2(0.0, float(k) * sample_step) : vec2(float(k) * sample_step, 0.0);
        vec4 morphology_1st_pass_pixel = texture2D(morph_1st_pass_texture, texcoord + sample_shift);
        max_of_y = max(max_of_y, morphology_1st_pass_pixel[1]);
        min_of_y = min(min_of_y, morphology_1st_pass_pixel[0]);
        vec3 src_rbg = texture2D(input_image_texture, texcoord + sample_shift).rgb;
        vec3 src_ycbcr = RGBToYCbCr * src_rbg;
        avg_of_cb += src_ycbcr[1];
        avg_of_cr += src_ycbcr[2];
    }
    avg_of_cb /= float(half_kernel_size * 2 + 1);
    avg_of_cr /= float(half_kernel_size * 2 + 1);
    float open_y = max_of_y;
    float close_y = min_of_y;
    vec3 src_rgb = texture2D(input_image_texture, texcoord).rgb;
    float src_y = 0.299 * src_rgb.r + 0.587 * src_rgb.g + 0.114 * src_rgb.b;
    float result_y;
    if (ToCPUPixel(close_y) > ToCPUPixel(src_y) && ToCPUPixel(open_y) < ToCPUPixel(src_y))
        result_y = mix(open_y, close_y, 0.5);
    else if (ToCPUPixel(close_y) > ToCPUPixel(src_y))
        result_y = mix(src_y, close_y, 0.75);
    else if (ToCPUPixel(open_y) < ToCPUPixel(src_y))
        result_y = mix(src_y, open_y, 0.5);
    else
        result_y = mix(open_y, close_y, 0.5);
    vec3 src_ycbcr = RGBToYCbCr * src_rgb;
    src_ycbcr[0] = result_y;
    src_ycbcr[1] = avg_of_cb;
    src_ycbcr[2] = avg_of_cr;
    vec3 wrinkless_rgb = YCbCrToRGB * src_ycbcr;
    gl_FragColor = vec4(wrinkless_rgb, 1.0);
}
int ToCPUPixel(float gpu_value)
{
    float cpu_value = gpu_value * 255.0;
    return (cpu_value < 0.0)? int(cpu_value - 0.5) : int(cpu_value + 0.5);
}
