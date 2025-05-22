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
//   Feel free to make changes to any of the code (or steal it)
//
//   Check out more of my work on GitHub, Modrinth, Or Curseforge :)
//

#version 150 compatibility

#include "lib/functions.glsl"
#include "settings.glsl"

in vec2 texCoord;

uniform sampler2D colortex0;

layout(location = 0) out vec4 fragColor;

void main() {
    vec2 res = textureSize(colortex0, 0);
    if (BLUR) {
        fragColor = gaussianBlur(colortex0, texCoord, res, BLUR_SCALE);
    } else {
        fragColor = texture(colortex0, texCoord);
    }

}
