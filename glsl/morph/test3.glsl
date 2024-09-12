precision highp float;
uniform sampler2D input_image_texture;
uniform float frame_width;
uniform int rotation;
uniform int half_kernel_size;
varying vec2 texcoord;
varying vec2 lipstick_texcoord;
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
    for (int k = -half_kernel_size; k <= half_kernel_size; k++)
    { 
        vec2 sample_shift = (rotation == 0 || rotation == 180)? vec2(0.0, float(k) * sample_step) : vec2(float(k) * sample_step, 0.0);
        vec3 color = texture2D(input_image_texture, texcoord + sample_shift).rgb;
        float gray = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
        max_of_y = max(gray, max_of_y);
        min_of_y = min(gray, min_of_y);
    }
    gl_FragColor = vec4(max_of_y, min_of_y, 0.0, 0.0);
}
