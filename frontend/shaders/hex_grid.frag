#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uResolution;

out vec4 fragColor;

// ─── Hex grid SDF ───
// Returns: xy = nearest hex center, z = edge distance
vec4 hexCoord(vec2 p) {
    const vec2 s = vec2(1.0, 1.7320508);  // 1, sqrt(3)
    const vec2 h = s * 0.5;

    vec2 a = mod(p, s) - h;
    vec2 b = mod(p - h, s) - h;

    vec2 gv;
    if (length(a) < length(b))
        gv = a;
    else
        gv = b;

    // Distance to nearest edge
    vec2 ab = abs(gv);
    float edgeDist = max(dot(ab, normalize(s)), ab.x);

    return vec4(gv, edgeDist, 0.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 center = uResolution * 0.5;
    vec2 uv = fragCoord - center;

    // Distance from screen center (normalized)
    float maxDist = length(center);
    float dist = length(uv);
    float normDist = dist / maxDist;

    // ─── Background gradient ───
    vec3 bgCenter = vec3(0.043, 0.082, 0.125);  // #0B1520
    vec3 bgMid    = vec3(0.027, 0.063, 0.102);  // #07101A
    vec3 bgEdge   = vec3(0.0);                   // #000000

    vec3 bg = mix(bgCenter, bgMid, smoothstep(0.0, 0.5, normDist));
    bg = mix(bg, bgEdge, smoothstep(0.5, 1.0, normDist));

    // ─── Hex grid ───
    float hexScale = 0.045;  // ~22px hex radius equivalent
    vec2 hexUV = fragCoord * hexScale;
    vec4 hc = hexCoord(hexUV);

    // Edge line: thin lines at hex boundaries
    float hexSize = 0.5;
    float edgeLine = smoothstep(hexSize - 0.02, hexSize, hc.z);

    // Dot at hex corners (vertices): small bright dots
    float dotDist = length(hc.xy);
    float dot = smoothstep(0.48, 0.5, dotDist) * (1.0 - smoothstep(0.5, 0.52, dotDist));
    // Alternative: dots at edge intersections
    float vertexDot = 1.0 - smoothstep(0.0, 0.06, abs(hc.z - hexSize));
    vertexDot *= smoothstep(0.38, 0.5, dotDist);

    // ─── Radial mask: invisible at center, visible at edges ───
    float startFrac = 0.42;
    float mask = 0.0;
    if (normDist > startFrac) {
        float t = min((normDist - startFrac) / (1.0 - startFrac), 1.0);
        mask = t * t * (3.0 - 2.0 * t);  // smootherstep
    }

    // ─── Pulse wave ───
    float pulseSpeed = 0.005;
    float pulseWidth = 0.28;

    float pulsePhase = 0.0;
    float pulse = 0.0;
    if (normDist > startFrac) {
        float d = (normDist - startFrac) / (1.0 - startFrac);
        float tPulse = fract(uTime * pulseSpeed);
        float phase = mod(d - tPulse + 1.0, 1.0);
        if (phase < pulseWidth * 4.0) {
            pulse = exp(-(phase * phase) / (2.0 * pulseWidth * pulseWidth));
        }
    }

    // ─── Compose ───
    // Static grey grid lines
    float gridAlpha = edgeLine * mask * 0.11;
    vec3 gridColor = vec3(0.608, 0.639, 0.667);  // rgb(155, 163, 170)

    // Teal pulse on grid
    vec3 tealColor = vec3(0.004, 0.949, 0.949);  // #01F2F2
    float pulseGridAlpha = edgeLine * pulse * mask * 0.13;

    // Vertex dots
    float dotAlpha = vertexDot * mask * 0.50;
    float pulseDotAlpha = vertexDot * pulse * mask * 0.18;

    // Final compositing
    vec3 finalColor = bg;
    finalColor += gridColor * gridAlpha;
    finalColor += tealColor * pulseGridAlpha;
    finalColor += gridColor * dotAlpha;
    finalColor += tealColor * pulseDotAlpha;

    fragColor = vec4(finalColor, 1.0);
}
