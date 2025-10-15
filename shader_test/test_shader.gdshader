shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 viewport_size = vec2(1600, 900);
uniform vec2 virtual_resolution = vec2(320, 240); 
uniform float color_quantization = 1.0; // 

// CRT эффекты
uniform float scanline_strength = 0.3;
uniform float vignette_strength = 0.3;
uniform float chroma_aberration = 0.0002;

// Дизеринг 
const float ps1_dither[16] = float[16](
    -4.0, 0.0, -3.0, 1.0,
    2.0, -2.0, 3.0, -1.0,
    -3.0, 1.0, -4.0, 0.0,
    3.0, -1.0, 2.0, -2.0
);

// Квантование
vec3 original_quantize(vec3 color) {
    return floor((color * 255.0) / 8.0) / 31.0;
}

// Смешанное квантование
vec3 mixed_quantize(vec3 color) {
    vec3 original = original_quantize(color);
    return mix(color, original, color_quantization);
}

// CRT эффекты
vec3 apply_scanlines(vec3 color, vec2 uv) {
    float scanline = sin(uv.y * viewport_size.y * 3.14159) * 0.3 + 0.7;
    scanline = mix(1.0, scanline, scanline_strength);
    return color * scanline;
}

vec3 apply_vignette(vec3 color, vec2 uv) {
    vec2 centered = uv - 0.5;
    float vignette = 1.0 - dot(centered, centered) * vignette_strength;
    return color * vignette;
}

vec3 apply_chroma_aberration(vec2 uv) {
    if (chroma_aberration <= 0.0001) {
        return texture(screen_texture, uv).rgb;
    }
    
    vec2 offset = vec2(chroma_aberration, 0.00005);
    vec3 color;
    color.r = texture(screen_texture, uv + offset).r;
    color.g = texture(screen_texture, uv).g;
    color.b = texture(screen_texture, uv - offset).b;
    return color;
}

void fragment() {
  
    vec3 screen_color = texture(screen_texture, UV).rgb;
    
    screen_color = mixed_quantize(screen_color);
    
    vec2 virtual_pos = floor(FRAGCOORD.xy * (virtual_resolution / viewport_size));
    int x = int(mod(virtual_pos.x, 4.0));
    int y = int(mod(virtual_pos.y, 4.0));
    int index = y * 4 + x;
    float dither_offset = (ps1_dither[index] / 8.0);
    screen_color += dither_offset * 0.1;
    
    screen_color = apply_chroma_aberration(UV);
    screen_color = apply_scanlines(screen_color, UV);
    screen_color = apply_vignette(screen_color, UV);
    
    COLOR = vec4(screen_color, 1.0);
}