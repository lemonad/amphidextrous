local Class = require("class")
local C = Class:derive("Color")

-- Color to RGB value table for Lua coding with Corona
-- Color values copied from "http://www.w3.org/TR/SVG/types.html#ColorKeywords"
--
-- Usage for Corona toolkit:
-- add this file "colors-rgb.lua" to your working directory
-- add following directive to any file that will use the colors by name:
-- require "colors-rgb"
--
-- in the code, instead of using for example "{210, 105, 30}" for the "chocolate" color,
-- use "colorsRGB.chocolate" or colorsRGB[chocolate]
-- or if you need the individual R,G,B values, you can use either:
-- colorsRGB.chocolate[1] or colorsRGB.R("chocolate") for the R-value
-- or if you need the RGB values for a function list, you can use
-- colorsRGB.RGB("chocolate") that returns the multi value list "210 105 30"
-- this can be used for input in for example "body:setFillColor()", like:
-- body:setFillColor(colorsRGB.RGB("chocolate"))
--
-- Enjoy, Frank (Sep 19, 2010)

local hex_colors = { 0x43002a, 0x890027, 0xd9243c, 0xff6157, 0xffb762, 0xc76e46, 0x73392e, 0x34111f, 0x030710, 0x273b2d, 0x458239, 0x9cb93b, 0xffd832, 0xff823b, 0xd1401f, 0x7c191a, 0x310c1b, 0x833f34, 0xeb9c6e, 0xffdaac, 0xffffe4, 0xbfc3c6, 0x6d8a8d, 0x293b49, 0x041528, 0x033e5e, 0x1c92a7, 0x77d6c1, 0xffe0dc, 0xff88a9, 0xc03b94, 0x601761 }

local named_colors = {
  aliceblue = {240, 248, 255},
  antiquewhite = {250, 235, 215},
  aqua = { 0, 255, 255},
  aquamarine = {127, 255, 212},
  azure = {240, 255, 255},
  beige = {245, 245, 220},
  bisque = {255, 228, 196},
  black = { 0, 0, 0},
  blanchedalmond = {255, 235, 205},
  blue = { 0, 0, 255},
  blueviolet = {138, 43, 226},
  brown = {165, 42, 42},
  burlywood = {222, 184, 135},
  cadetblue = { 95, 158, 160},
  chartreuse = {127, 255, 0},
  chocolate = {210, 105, 30},
  coral = {255, 127, 80},
  cornflowerblue = {100, 149, 237},
  cornsilk = {255, 248, 220},
  crimson = {220, 20, 60},
  cyan = { 0, 255, 255},
  darkblue = { 0, 0, 139},
  darkcyan = { 0, 139, 139},
  darkgoldenrod = {184, 134, 11},
  darkgray = {169, 169, 169},
  darkgreen = { 0, 100, 0},
  darkgrey = {169, 169, 169},
  darkkhaki = {189, 183, 107},
  darkmagenta = {139, 0, 139},
  darkolivegreen = { 85, 107, 47},
  darkorange = {255, 140, 0},
  darkorchid = {153, 50, 204},
  darkred = {139, 0, 0},
  darksalmon = {233, 150, 122},
  darkseagreen = {143, 188, 143},
  darkslateblue = { 72, 61, 139},
  darkslategray = { 47, 79, 79},
  darkslategrey = { 47, 79, 79},
  darkturquoise = { 0, 206, 209},
  darkviolet = {148, 0, 211},
  deeppink = {255, 20, 147},
  deepskyblue = { 0, 191, 255},
  dimgray = {105, 105, 105},
  dimgrey = {105, 105, 105},
  dodgerblue = { 30, 144, 255},
  firebrick = {178, 34, 34},
  floralwhite = {255, 250, 240},
  forestgreen = { 34, 139, 34},
  fuchsia = {255, 0, 255},
  gainsboro = {220, 220, 220},
  ghostwhite = {248, 248, 255},
  gold = {255, 215, 0},
  goldenrod = {218, 165, 32},
  gray = {128, 128, 128},
  grey = {128, 128, 128},
  green = { 0, 128, 0},
  greenyellow = {173, 255, 47},
  honeydew = {240, 255, 240},
  hotpink = {255, 105, 180},
  indianred = {205, 92, 92},
  indigo = { 75, 0, 130},
  ivory = {255, 255, 240},
  khaki = {240, 230, 140},
  lavender = {230, 230, 250},
  lavenderblush = {255, 240, 245},
  lawngreen = {124, 252, 0},
  lemonchiffon = {255, 250, 205},
  lightblue = {173, 216, 230},
  lightcoral = {240, 128, 128},
  lightcyan = {224, 255, 255},
  lightgoldenrodyellow = {250, 250, 210},
  lightgray = {211, 211, 211},
  lightgreen = {144, 238, 144},
  lightgrey = {211, 211, 211},
  lightpink = {255, 182, 193},
  lightsalmon = {255, 160, 122},
  lightseagreen = { 32, 178, 170},
  lightskyblue = {135, 206, 250},
  lightslategray = {119, 136, 153},
  lightslategrey = {119, 136, 153},
  lightsteelblue = {176, 196, 222},
  lightyellow = {255, 255, 224},
  lime = { 0, 255, 0},
  limegreen = { 50, 205, 50},
  linen = {250, 240, 230},
  magenta = {255, 0, 255},
  maroon = {128, 0, 0},
  mediumaquamarine = {102, 205, 170},
  mediumblue = { 0, 0, 205},
  mediumorchid = {186, 85, 211},
  mediumpurple = {147, 112, 219},
  mediumseagreen = { 60, 179, 113},
  mediumslateblue = {123, 104, 238},
  mediumspringgreen = { 0, 250, 154},
  mediumturquoise = { 72, 209, 204},
  mediumvioletred = {199, 21, 133},
  midnightblue = { 25, 25, 112},
  mintcream = {245, 255, 250},
  mistyrose = {255, 228, 225},
  moccasin = {255, 228, 181},
  navajowhite = {255, 222, 173},
  navy = { 0, 0, 128},
  oldlace = {253, 245, 230},
  olive = {128, 128, 0},
  olivedrab = {107, 142, 35},
  orange = {255, 165, 0},
  orangered = {255, 69, 0},
  orchid = {218, 112, 214},
  palegoldenrod = {238, 232, 170},
  palegreen = {152, 251, 152},
  paleturquoise = {175, 238, 238},
  palevioletred = {219, 112, 147},
  papayawhip = {255, 239, 213},
  peachpuff = {255, 218, 185},
  peru = {205, 133, 63},
  pink = {255, 192, 203},
  plum = {221, 160, 221},
  powderblue = {176, 224, 230},
  purple = {128, 0, 128},
  red = {255, 0, 0},
  rosybrown = {188, 143, 143},
  royalblue = { 65, 105, 225},
  saddlebrown = {139, 69, 19},
  salmon = {250, 128, 114},
  sandybrown = {244, 164, 96},
  seagreen = { 46, 139, 87},
  seashell = {255, 245, 238},
  sienna = {160, 82, 45},
  silver = {192, 192, 192},
  skyblue = {135, 206, 235},
  slateblue = {106, 90, 205},
  slategray = {112, 128, 144},
  slategrey = {112, 128, 144},
  snow = {255, 250, 250},
  springgreen = { 0, 255, 127},
  steelblue = { 70, 130, 180},
  tan = {210, 180, 140},
  teal = { 0, 128, 128},
  thistle = {216, 191, 216},
  tomato = {255, 99, 71},
  turquoise = { 64, 224, 208},
  violet = {238, 130, 238},
  wheat = {245, 222, 179},
  white = {255, 255, 255},
  whitesmoke = {245, 245, 245},
  yellow = {255, 255, 0},
  yellowgreen = {154, 205, 50}
}

C.color_keys = {}
for k, c in pairs(hex_colors) do
  C.color_keys[#C.color_keys + 1] = k
end

-- C.color_keys = {}
-- for k, c in pairs(named_colors) do
--   C.color_keys[#C.color_keys + 1] = k
-- end

local function hsl_to_rgb(h, s, l)
    if s == 0 then return l, l, l end
    local function to(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < .16667 then return p + (q - p) * 6 * t end
        if t < .5 then return q end
        if t < .66667 then return p + (q - p) * (.66667 - t) * 6 end
        return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return to(p, q, h + .33334), to(p, q, h), to(p, q, h - .33334)
end

local function rgb_to_hsl(r, g, b)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local bm = max + min
  local h = bm / 2
  if max == min then return 0, 0, h end
  local s, l = h, h
  local d = max - min
  s = l > .5 and d / (2 - bm) or d / bm
  if max == r then h = (g - b) / d + (g < b and 6 or 0)
  elseif max == g then h = (b - r) / d + 2
  elseif max == b then h = (r - g) / d + 4
  end
  return h * .16667, s, l
end

function C:new(r, g, b, a)
  self.r = r or 0.0
  self.g = g or 0.0
  self.b = b or 0.0
  self.a = a or 1.0
end

-- function C:R(name)
--   return named_colors[name][1]
-- end
--
-- function C:G(name)
--   return named_colors[name][2]
-- end
--
-- function C:B(name)
--   return named_colors[name][3]
-- end

function C:from_hex(color, a)
  return C(
    bit.rshift(bit.band(color, 0xff0000), 16) / 255.0,
    bit.rshift(bit.band(color, 0xff00), 8) / 255.0,
    bit.band(color, 0xff) / 255.0,
    a
  )
end

function C:color_from_index(ix, a)
  local color = hex_colors[C.color_keys[ix]]
  return C:from_hex(color, a)
end

function C:random_color(a)
  local ix = math.random(1, #C.color_keys)
  local color = hex_colors[C.color_keys[ix]]
  return C:from_hex(color, a)
end

function C:random_color_named(a)
  local ix = math.random(1, #self.color_keys)
  local color = named_colors[self.color_keys[ix]]
  return C(color[1] / 255.0, color[2] / 255.0, color[3] / 255.0, a or 1.0)
end

-- amount is [0, 1] where 0 is the original lightness and 1 is white
function C:lighten(amount)
  local h, s, l = rgb_to_hsl(self.r, self.g, self.b)
  l = amount + (1.0 - amount) * l
  local r, g, b = hsl_to_rgb(h, s, l)
  return C(r, g, b, self.a)
end

-- amount is [0, 1] where 0 is the original lightness and 1 is black
function C:darken(amount)
  local h, s, l = rgb_to_hsl(self.r, self.g, self.b)
  l = (1.0 - amount) * l
  local r, g, b = hsl_to_rgb(h, s, l)
  return C(r, g, b, self.a)
end

function C:rgba(alpha)
  local a = alpha or self.a
  return { self.r, self.g, self.b, a }
end

function C:print()
  print(self.r, self.g, self.b, self.a)
end

return C
