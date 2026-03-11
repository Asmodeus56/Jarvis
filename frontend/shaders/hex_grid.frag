#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uResolution;

out vec4 fragColor;

// ─── Hex grid SDF ───
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

    vec2 ab = abs(gv);
    float edgeDist = max(dot(ab, normalize(s)), ab.x);

    return vec4(gv, edgeDist, 0.0);
}

// ─── Heartbeat double-pulse ───
// Two pulses close together like a heartbeat: lub-dub
float heartbeatPulse(float d, float tPulse) {
    float pw = 0.12;     // pulse width (narrower for sharper beats)
    float gap = 0.08;    // gap between first and second beat

    // First beat (lub)
    float phase1 = mod(d - tPulse + 1.0, 1.0);
    float p1 = 0.0;
    if (phase1 < pw * 3.0) {
        p1 = exp(-(phase1 * phase1) / (2.0 * pw * pw));
    }

    // Second beat (dub) — follows closely, slightly weaker
    float phase2 = mod(d - tPulse + 1.0 - gap, 1.0);
    float p2 = 0.0;
    if (phase2 < pw * 3.0) {
        p2 = exp(-(phase2 * phase2) / (2.0 * pw * pw)) * 0.65;
    }

    return max(p1, p2);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 center = uResolution * 0.5;
    vec2 uv = fragCoord - center;

    float maxDist = length(center);
    float dist = length(uv);
    float normDist = dist / maxDist;

    // ─── Background gradient (lighter center) ───
    vec3 bgCenter = vec3(0.063, 0.114, 0.180);  // #101D2E
    vec3 bgMid    = vec3(0.027, 0.063, 0.102);  // #07101A
    vec3 bgEdge   = vec3(0.0);

    vec3 bg = mix(bgCenter, bgMid, smoothstep(0.0, 0.5, normDist));
    bg = mix(bg, bgEdge, smoothstep(0.5, 1.0, normDist));

    // ─── Hex grid (1.5× larger hexagons) ───
    float hexScale = 0.030;
    vec2 hexUV = fragCoord * hexScale;
    vec4 hc = hexCoord(hexUV);

    // --- Edge lines ---
    float hexSize = 0.5;
    float edgeLine = smoothstep(hexSize - 0.015, hexSize, hc.z);

    // --- Dots at intersections (hex vertices) ---
    // Hex vertices are at maximum distance from cell center where edges meet.
    // In hex SDF space, vertices are at corners where dotDist is near hexSize
    // and edgeDist is also at hexSize. We detect by checking both conditions.
    float dotDist = length(hc.xy);
    // Dot at vertices: where we're at the hex boundary AND far from center
    float atEdge = 1.0 - smoothstep(0.0, 0.025, abs(hc.z - hexSize));
    float atCorner = smoothstep(0.42, 0.50, dotDist);
    float vertexDot = atEdge * atCorner;
    // Make dots rounder: use distance from the nearest vertex approximation
    // The vertex positions in hex-cell space are at the 6 corners
    float dotRadius = 0.06;
    // Use the grid-space position to create round dots
    vec2 toCorner = hc.xy;
    float cornerAngle = atan(toCorner.y, toCorner.x);
    // Snap to nearest 60-degree vertex
    float snapAngle = floor(cornerAngle / 1.0472 + 0.5) * 1.0472; // pi/3
    vec2 nearestVertex = vec2(cos(snapAngle), sin(snapAngle)) * 0.5;
    float vertDist = length(hc.xy - nearestVertex);
    float roundDot = smoothstep(dotRadius, dotRadius * 0.3, vertDist);

    // ─── Radial mask: invisible at center, visible at edges ───
    float startFrac = 0.40;  // grid starts further from center
    float mask = 0.0;
    if (normDist > startFrac) {
        float t = min((normDist - startFrac) / (1.0 - startFrac), 1.0);
        mask = t * t * (3.0 - 2.0 * t);
    }

    // ─── Heartbeat pulse ───
    float pulseSpeed = 0.003;  // slow heartbeat rhythm
    float pulse = 0.0;
    if (normDist > startFrac) {
        float d = (normDist - startFrac) / (1.0 - startFrac);
        float tPulse = fract(uTime * pulseSpeed);
        pulse = heartbeatPulse(d, tPulse);
    }

    // ─── Compose — very low static opacity, pulse provides the life ───
    vec3 gridColor = vec3(0.608, 0.639, 0.667);  // grey
    vec3 tealColor = vec3(0.004, 0.949, 0.949);  // #01F2F2

    // Static grid lines — very faint
    float gridAlpha = edgeLine * mask * 0.04;

    // Pulse lights up the grid lines
    float pulseGridAlpha = edgeLine * pulse * mask * 0.15;

    // Static dots — faint
    float dotAlpha = roundDot * mask * 0.30;

    // Pulse lights up dots
    float pulseDotAlpha = roundDot * pulse * mask * 0.35;

    // Final compositing
    vec3 finalColor = bg;
    finalColor += gridColor * gridAlpha;
    finalColor += tealColor * pulseGridAlpha;
    finalColor += gridColor * dotAlpha;
    finalColor += tealColor * pulseDotAlpha;

    fragColor = vec4(finalColor, 1.0);
}
