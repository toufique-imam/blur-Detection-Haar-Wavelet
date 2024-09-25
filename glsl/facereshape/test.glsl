precision mediump float; 
 
varying vec2 texture_coordinate; 
uniform sampler2D rootImageTexture; 
uniform sampler2D inputImageTexture; 
 
uniform vec2 sampling_offset_start; 
uniform vec2 sampling_step; 
 
uniform float strength; 
 
const vec3 reference_skin = vec3(0.88, 0.79, 0.79); 
void main() 
{ 
    vec4 average_info = texture2D(inputImageTexture, texture_coordinate); 
 
    const int one_side_sampling_number = 2; 
    vec2 sampling_offset = sampling_offset_start; 
    for (int i = 0; i < one_side_sampling_number; i++) 
    { 
        vec4 surround_0 = texture2D(inputImageTexture, texture_coordinate + sampling_offset); 
        vec4 surround_1 = texture2D(inputImageTexture, texture_coordinate - sampling_offset); 
        average_info += surround_0 + surround_1; 
 
        sampling_offset += sampling_step; 
    } 
 
    average_info /= float(2 * one_side_sampling_number + 1); 
 
    float mean = average_info.g; 
    float sqaure_mean = average_info.a;  
    float variance = max(0.00001, sqaure_mean - mean * mean); 
 
    float epsilon = strength; 
    float src_weight = variance / (variance + (epsilon * epsilon)); 
 
    const float base_src_weight = 0.2; 
    src_weight = src_weight + base_src_weight - src_weight * base_src_weight; 
    src_weight = 1.0 - ((1.0 - src_weight) * min(1.0, average_info.g * 2.5)); 
 
   vec4 root_source = texture2D(rootImageTexture, texture_coordinate); 
 
    average_info = mix(average_info, root_source, src_weight); 
 
    average_info.rgb = max(vec3(0.0), (average_info.rgb - vec3(0.031372)) * vec3(1.0324)); 
 
    float reference_skin_weight = dot(average_info.rgb, reference_skin) / 18.0;    average_info.rgb = mix(average_info.rgb, reference_skin, reference_skin_weight); 
    gl_FragColor = vec4(average_info.rgb, 1.0); 
} 
