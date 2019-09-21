#pragma language glsl3
uniform float time;
uniform Image handdrawn;
uniform vec2 wave_seed;
uniform vec4 top_color;
uniform vec4 bottom_color;
uniform vec4 line_color;
uniform vec4 under_color;

float pi = atan(1.0) * 4.0;
float line_width = 5.0;
float half_width = line_width / 2.0;
float quarter_width = line_width / 4.0;

highp float rand(vec2 co) {
  highp float a = 12.9898;
  highp float b = 78.233;
  highp float c = 43758.5453;
  highp float dt= dot(co.xy, vec2(a,b));
  highp float sn= mod(dt, 3.14);
  return fract(sin(sn) * c);
}

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {
  float screen_width = love_ScreenSize.x;
  float screen_height = 530.0;
  vec2 screen_coords_norm = vec2(
      screen_coords.x / screen_width,
      screen_coords.y / screen_height
    );
  float n = 800.0;
  float s = time;
  float t = time;

  vec2 seed = vec2(5050, 9090);
  vec2 coord;
  // line_color = bottom_color;
  // line_color.a = 0.5;

  vec4 ret_color;
  vec4 above_color = bottom_color;
  vec4 below_color = bottom_color;

  float y = -600;

  // const vec3 MyArray[4]=vec3[4](
  //   vec3(1.5,34.4,3.2),
  //   vec3(1.6,34.1,1.2),
  //   vec3(18.981777,6.258294,-27.141813),
  //   vec3(1.0,3.0,1.0) );
//  const vec4 r[10 * 3] = vec4[10 * 3](
//    vec4(40, 10, 5, 0),
//    vec4(4.18, 1.9, 8.3, pi),
//    vec4(0.5, 1.33, 1.0, 0.7),
//
//    vec4(33, 11, 6, 0),
//    vec4(3.58, 1.6, 5.2, 0),
//    vec4(0.9, 2.33, 1, 1.9),
//
//    vec4(37, 12, 8, 0),
//    vec4(1.88, 1.7, 6.5, 0),
//    vec4(0.95, 2.33, 2, 1.2),
//
//    vec4(38, 10, 12, 0),
//    vec4(9.66, 1.4, 5.1, 0),
//    vec4(1.0, 5.33, 2.0, 1.2),
//
//    vec4(44, 8, 11, 0),
//    vec4(1.66, 2.4, 3.9 , 0),
//    vec4(0.8, 1.88, 2.3, 1.9),
//
//    vec4(37, 5, 14, 0),
//    vec4(2.11, 3.0, 2.7, 0),
//    vec4(0.82, 6.19, 3.33, 2.4),
//
//    vec4(
//    );

  // float y1 = 40 +      sin(4.18 + 1.9 * time + pi * 8.3 * screen_coords_norm.x) * 10 + sin(screen_coords_norm.x * pi + time * 0.5) *  cos(1.33 + pi * 1    * screen_coords_norm.x + pi * 0.7 * time) * 5;
  // float y2 = 33 + y1 + sin(3.58 + 1.6 * time + pi * 5.2 * screen_coords_norm.x) * 11 + sin(                            time * 0.9) *  cos(2.33 + pi * 1    * screen_coords_norm.x + pi * 1.9 * time) * 6;
  // float y3 = 37 + y2 + sin(1.88 + 1.7 * time + pi * 6.5 * screen_coords_norm.x) * 12 + sin(                            time * 0.95) * cos(2.33 + pi * 2    * screen_coords_norm.x + pi * 1.2 * time) * 8;
  // float y4 = 38 + y3 + sin(9.66 + 1.4 * time + pi * 5.1 * screen_coords_norm.x) * 10 + sin(                            time * 1.0) *  cos(5.33 + pi * 2    * screen_coords_norm.x + pi * 1.2 * time) * 12;
  // float y5 = 44 + y4 + sin(1.66 + 2.4 * time + pi * 3.9 * screen_coords_norm.x) * 8 +  sin(                            time * 0.8) *  cos(1.88 + pi * 2.3  * screen_coords_norm.x + pi * 1.9 * time) * 11;
  // float y6 = 37 + y5 + sin(2.11 + 3.0 * time + pi * 2.7 * screen_coords_norm.x) * 5 +  sin(                            time * 0.82) * cos(6.19 + pi * 3.33 * screen_coords_norm.x + pi * 2.4 * time) * 14;

  vec2 wseed = wave_seed;

  for (int i = 0; i < 10; ++i) {
    if (i == 9) {
      above_color = top_color;
    }

    float r[8];
    r[0] = rand(wave_seed) * 2.0 * pi + i * 0.1;
    r[1] = rand(wave_seed * r[0]) * pi / 2.0;
    r[2] = rand(wave_seed * r[1]) * 2.0 * pi;
    r[3] = rand(wave_seed * r[2]) * pi / 5.0;
    r[4] = rand(wave_seed * r[3]) * pi / 4.0;
    r[5] = rand(wave_seed * r[4]) * 2 * pi;
    r[6] = rand(wave_seed * r[5]) * pi;
    r[7] = rand(wave_seed * r[6]) * pi;

    y = y + 105 + sin(r[0] + r[1] * t + pi * r[2] * screen_coords_norm.x) * 10.0 +
                 sin(screen_coords_norm.x * r[3] + t * r[4]) *
                 cos(r[5] + pi * r[6] * screen_coords_norm.x + pi * r[7] * t *
                     0.05) * 5.0;
    // y = y + 20;

    // Generate subtle noise to mimic handdrawn lines.
    float k = floor(screen_coords.x / 5.0);
    vec2 drawn_noise_seed = vec2(i + k, k);
    float drawn_noise = rand(drawn_noise_seed) * 0.5;

    // Mimic hand movements.
    coord.x = screen_coords.x / n;
    coord.y = 0.05 + i / 10.0;
    float hand_movement = (-Texel(handdrawn, coord).y + 0.5) * 6.0;

    // float noise_y = y + (noise.y - 0.5) * 12 + rand(seed) * 0.5;
    float noise_y = y + hand_movement + drawn_noise;

    float delta = screen_height - noise_y - screen_coords.y;
    float abs_delta = abs(delta);
    if (delta >= half_width) {
      continue;
    }

    if (delta >= 0 && delta < half_width) {
      return mix(
          line_color,
          above_color,
          max(min((abs_delta - quarter_width) / quarter_width, 1.0), 0.0)
          );
    } else if (i == 0 && delta < 0) {
      return mix(
          line_color,
          under_color,
          max(min((abs_delta - quarter_width) / quarter_width, 1.0), 0.0)
          );
    } else if (delta < 0 && abs_delta < half_width) {
      return mix(
          line_color,
          below_color,
          max(min((abs_delta - quarter_width) / quarter_width, 1.0), 0.0)
          );
    } else {
      return below_color;
    }
  }
  // top_color = vec4(154.0 / 255, 185.0 / 255, 169.0 / 255, 1.0);

  return top_color;



  // vec2 coord;
  // coord.y = 0;
  // coord.x = screen_coords.x / n + 0.0 * (screen_width / n);
  // vec4 noise1 = Texel(handdrawn, coord);
  // coord.x = screen_coords.x / n + 0.0 * (screen_width / n);
  // vec4 noise2 = Texel(handdrawn, coord);
  // coord.x = screen_coords.x / n + 0.0 * (screen_width / n);
  // vec4 noise3 = Texel(handdrawn, coord);
  // coord.x = screen_coords.x / n + 0.0 * (screen_width / n);
  // vec4 noise4 = Texel(handdrawn, coord);
  // coord.x = screen_coords.x / n + 0.0 * (screen_width / n);
  // vec4 noise5 = Texel(handdrawn, coord);
  // coord.x = screen_coords.x / n + 0.0 * (screen_width / n);
  // vec4 noise6 = Texel(handdrawn, coord);

  // // return vec4(noise1.x, 0, 0, 1);

  // vec2 screen_coords_norm = vec2(
  //     screen_coords.x / screen_width,
  //     screen_coords.y / screen_height
  //   );
  // float y1 = 40 + sin(4.18 + 1.9 * time + pi * 8.3 * screen_coords_norm.x) * 10 +
  //  sin(screen_coords_norm.x * pi + time * 0.5) * cos(1.33 + pi * screen_coords_norm.x + pi * 0.7 * time) * 5;
  // float y2 = 33 + y1 + sin(3.58 + 1.6 * time + pi * 5.2 * screen_coords_norm.x) * 11 +
  //  sin(time * 0.9) * cos(2.33 + pi * screen_coords_norm.x + pi * 1.9 * time) * 6;
  // float y3 = 37 + y2 + sin(1.88 + 1.7 * time + pi * 6.5 * screen_coords_norm.x) * 12 +
  //  sin(time * 0.95) * cos(2.33 + pi * 2 * screen_coords_norm.x + pi * 1.2 * time) * 8;
  // float y4 = 38 + y3 + sin(9.66 + 1.4 * time + pi * 5.1 * screen_coords_norm.x) * 10 +
  //  sin(time) * cos(5.33 + pi * 2 * screen_coords_norm.x + pi * 1.2 * time) * 12;
  // float y5 = 44 + y4 + sin(1.66 + 2.4 * time + pi * 3.9 * screen_coords_norm.x) * 8 +
  //  sin(time * 0.8) * cos(1.88 + pi * 2.3 * screen_coords_norm.x + pi * 1.9 * time) * 11;
  // float y6 = 37 + y5 + sin(2.11 + 3.0 * time + pi * 2.7 * screen_coords_norm.x) * 5 +
  //  sin(time * 0.82) * cos(6.19 + pi * 3.33 * screen_coords_norm.x + pi * 2.4 * time) * 14;

  // float noise_y1 = y1 + (noise1.x - 0.5) * 59;
  // float noise_y2 = y2 + (noise2.x - 0.5) * 59;
  // float noise_y3 = y3 + (noise3.x - 0.5) * 59;
  // float noise_y4 = y4 + (noise4.x - 0.5) * 59;
  // float noise_y5 = y5 + (noise5.x - 0.5) * 59;
  // float noise_y6 = y6 + (noise6.x - 0.5) * 59;

  // vec4 ret_color;
  // if (screen_coords.y < screen_height - noise_y6 - 2) {
  //   ret_color = vec4(152.0 / 255, 182.0 / 255, 156.0 / 255, 1.0);
  // } else {
  //   ret_color = vec4(105.0 / 255, 145.0 / 255, 138.0 / 255, 1.0);
  // }

  // if ((screen_coords.y < screen_height - noise_y1 + 1.5 &&
  //      screen_coords.y > screen_height - noise_y1 - 1.5) ||
  //     (screen_coords.y < screen_height - noise_y2 + 1.5 &&
  //      screen_coords.y > screen_height - noise_y2 - 1.5) ||
  //     (screen_coords.y < screen_height - noise_y3 + 1.5 &&
  //      screen_coords.y > screen_height - noise_y3 - 1.5) ||
  //     (screen_coords.y < screen_height - noise_y4 + 1.5 &&
  //      screen_coords.y > screen_height - noise_y4 - 1.5) ||
  //     (screen_coords.y < screen_height - noise_y5 + 1.5 &&
  //      screen_coords.y > screen_height - noise_y5 - 1.5) ||
  //     (screen_coords.y < screen_height - noise_y6 + 1.5 &&
  //      screen_coords.y > screen_height - noise_y6 - 1.5)) {
  //   ret_color = vec4(92.0 / 255, 126.0 / 255, 113.0 / 255, 1.0);
  // }

  // return ret_color;

  // if (screen_coords.y < screen_dims.y - y6) {
  //   return vec4(0.0, 0.0, 0.6, 1.0);
  // } else if (screen_coords.y < screen_dims.y - y5) {
  //   return vec4(0.0, 0.0, 0.65, 1.0);
  // } else if (screen_coords.y < screen_dims.y - y4) {
  //   return vec4(0.0, 0.0, 0.7, 1.0);
  // } else if (screen_coords.y < screen_dims.y - y3) {
  //   return vec4(0.0, 0.0, 0.75, 1.0);
  // } else if (screen_coords.y < screen_dims.y - y2) {
  //   return vec4(0.0, 0.0, 0.8, 1.0);
  // } else if (screen_coords.y < screen_dims.y - y) {
  //   return vec4(0.0, 0.0, 0.85, 1.0);
  // } else {
  //   return vec4(0.0, 0.0, 0.9, 1.0);
  // }
}
