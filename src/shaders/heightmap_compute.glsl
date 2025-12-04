#version 450

// GPU Compute Shader for Deterministic Terrain Heightmap Generation
// Purpose: Generate seamless 32x32 heightmaps using tileable Perlin noise
// Input: chunk_x, chunk_y, world_seed (uniforms)
// Output: 32x32 heightmap texture (R32F format)

// ============================================
// CONSTANTS
// ============================================
const int TILE_SIZE = 256;  // Must match chunk coordinate system
const float TWO_PI = 6.28318530718;
const float ONE_OVER_PI = 0.31830988618;

// ============================================
// LAYOUT & UNIFORMS
// ============================================
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(r32f, binding = 0) uniform image2D heightmap_output;

uniform int chunk_x;      // Chunk coordinate X
uniform int chunk_y;      // Chunk coordinate Y
uniform int world_seed;   // World seed for deterministic generation

// ============================================
// HASH FUNCTION FOR DETERMINISTIC RANDOMNESS
// ============================================
uint hash(uint x) {
    x ^= x >> 16;
    x *= 0x7feb352du;
    x ^= x >> 15;
    return x;
}

uint hash2(uint x, uint y) {
    uint h = hash(x ^ hash(y));
    return h;
}

// ============================================
// IMPROVED PERLIN NOISE (Gradient-based)
// ============================================

// Fade function for smooth interpolation
float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Linear interpolation
float lerp(float a, float b, float t) {
    return a + (b - a) * t;
}

// Gradient dot product
float grad(uint hash_val, float x, float y) {
    uint h = hash_val & 15u;
    float u = h < 8u ? x : y;
    float v = h < 8u ? y : x;
    return ((h & 1u) == 0u ? u : -u) + ((h & 2u) == 0u ? v : -v);
}

// 2D Perlin Noise
float perlin_noise_2d(vec2 p) {
    vec2 pi = floor(p);
    vec2 pf = fract(p);

    // Hash grid corners
    uint h00 = hash2(uint(pi.x) + uint(world_seed), uint(pi.y));
    uint h10 = hash2(uint(pi.x + 1.0) + uint(world_seed), uint(pi.y));
    uint h01 = hash2(uint(pi.x) + uint(world_seed), uint(pi.y + 1.0));
    uint h11 = hash2(uint(pi.x + 1.0) + uint(world_seed), uint(pi.y + 1.0));

    // Gradients
    float g00 = grad(h00, pf.x, pf.y);
    float g10 = grad(h10, pf.x - 1.0, pf.y);
    float g01 = grad(h01, pf.x, pf.y - 1.0);
    float g11 = grad(h11, pf.x - 1.0, pf.y - 1.0);

    // Interpolation
    float u = fade(pf.x);
    float v = fade(pf.y);

    float n00 = lerp(g00, g10, u);
    float n01 = lerp(g01, g11, u);
    float n = lerp(n00, n01, v);

    return n * 0.5 + 0.5;  // Normalize to 0-1
}

// ============================================
// TILEABLE PERLIN NOISE WRAPPER
// ============================================
float tileable_perlin(vec2 p) {
    // Convert to tileable coordinates using sine wave wrapping
    // This ensures noise loops seamlessly at tile boundaries

    float x_wrapped = sin(p.x * TWO_PI / float(TILE_SIZE)) * float(TILE_SIZE) * ONE_OVER_PI;
    float y_wrapped = sin(p.y * TWO_PI / float(TILE_SIZE)) * float(TILE_SIZE) * ONE_OVER_PI;

    vec2 wrapped_p = vec2(x_wrapped, y_wrapped);

    return perlin_noise_2d(wrapped_p);
}

// ============================================
// ELEVATION GRADIENT SIMULATION
// ============================================
float elevation_gradient(vec2 world_pos) {
    // Creates natural elevation patterns using multi-octave noise

    float elevation = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float max_value = 0.0;

    // 4-octave Perlin for variation
    for (int i = 0; i < 4; i++) {
        elevation += amplitude * tileable_perlin(world_pos * frequency);
        max_value += amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }

    elevation /= max_value;

    return elevation * 0.5;  // Scale to reasonable range
}

// ============================================
// CRATER/FEATURE SIMULATION
// ============================================
float crater_simulation(vec2 world_pos) {
    // Creates natural depressions and peaks

    vec2 feature_pos = mod(world_pos, 128.0);
    float distance_to_center = length(feature_pos - vec2(64.0));

    // Crater: depression in terrain
    float crater = 0.15 * exp(-distance_to_center / 20.0);

    return -crater;  // Negative = depression
}

// ============================================
// MAIN COMPUTE SHADER
// ============================================
void main() {
    // Get pixel coordinates for this work item
    ivec2 pixel_coord = ivec2(gl_GlobalInvocationID.xy);

    // Calculate world position
    // chunk_x, chunk_y are chunk coordinates; each chunk is 32x32 pixels
    vec2 world_pos = vec2(
        float(chunk_x * 32 + pixel_coord.x),
        float(chunk_y * 32 + pixel_coord.y)
    );

    // Generate seamless height using tileable Perlin
    float height = tileable_perlin(world_pos);

    // Add elevation variation
    height += elevation_gradient(world_pos) * 0.3;

    // Add crater/feature detail
    height += crater_simulation(world_pos) * 0.2;

    // Clamp to valid range (0.0 - 1.0)
    height = clamp(height, 0.0, 1.0);

    // Write result to output texture
    imageStore(heightmap_output, pixel_coord, vec4(height, 0.0, 0.0, 1.0));
}
