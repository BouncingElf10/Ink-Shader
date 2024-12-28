//
//    __ __  __  __  ___    ____    __
//   |  V  |/  \| _\| __|   |  \ `v' /
//   | \_/ | /\ | v | _|    | -<`. .'
//   |_| |_|_||_|__/|___|   |__/ !_!
//
//    ____                         _             ______ _  __ __  ___
//   |  _ \                       (_)           |  ____| |/ _/_ |/ _ \
//   | |_) | ___  _   _ _ __   ___ _ _ __   __ _| |__  | | |_ | | | | |
//   |  _ < / _ \| | | | '_ \ / __| | '_ \ / _` |  __| | |  _|| | | | |
//   | |_) | (_) | |_| | | | | (__| | | | | (_| | |____| | |  | | |_| |
//   |____/ \___/ \__,_|_| |_|\___|_|_| |_|\__, |______|_|_|  |_|\___/
//
//   Feel free to make changes to any of the code (or steal it),
//   but remember steal like an artist, not like a copier :c
//
//   Check out more of my work on GitHub, Modrinth, Or Curseforge :)
//

#version 150 compatibility

#include "lib/kernels.glsl"
#include "lib/functions.glsl"
#include "settings.glsl"

uniform float thresholdLow = 0;
uniform float thresholdHigh = 1;
uniform float sigma;

uniform float white = 1.0;
uniform float black = BLACK_BRIGHTNESS;

in vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex4; // Blue Noise
uniform sampler2D colortex5; // Paper Tex
uniform sampler2D depthtex0;
uniform float frameTimeCounter;

layout(location = 0) out vec4 fragColor;

vec4 edgeDetect(sampler2D tex, int depth) {
    float gray = texture(tex, texCoord).r;

    mat3 kernel = gaussianKernel(0);
    float blurred = convolution(tex, texCoord, kernel, depth);

    float gradX = convolution(tex, texCoord, sobelX, depth);
    float gradY = convolution(tex, texCoord, sobelY, depth);

    float gradMag = length(vec2(gradX, gradY));
    float gradDir = atan(gradY, gradX);
    vec4 colorEdge;
    if (gradMag > thresholdHigh) {
        colorEdge = vec4(vec3(black), 1.0); // Strong edge
    } else {
        colorEdge = vec4(vec3(white), 1.0); // Weak edge
    }
    return colorEdge;
}

void main() {
    vec2 res = textureSize(colortex0, 0);
    // Edge detect the color buffer and depth buffer
    if ((edgeDetect(colortex0, 0).r != white || edgeDetect(depthtex0, 1) != white) && EDGE_DETECTION) {
        fragColor = vec4(vec3(black), 1.0);
    } else {
        //fragColor = vec4(vec3(white), 1.0);
        fragColor = texture(colortex5, texCoord) * PAPER_BRIGHTNESS;
        if (PAPER_COLOR) {
            fragColor = adjustHueSaturation(fragColor, PAPER_HUE * 360, PAPER_SATURATION);
        }
    }

    if (STIPPLING) {
        float scale = STIPPLING_SCALE;
        if (texture(colortex0, texCoord).r < texture(colortex4, texCoord * scale + (frameTimeCounter * 10) * NOISE).r && fragColor.r != 0.2) {
            fragColor = vec4(vec3(black), 1.0);
        }
    }
}
