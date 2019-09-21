local Class = require("class")
local C = Class:derive("Color")

local hex_colors = {
  0x43002a, 0x890027, 0xd9243c, 0xff6157,
  0xffb762, 0xc76e46, 0x73392e, 0x34111f,
  0x030710, 0x273b2d, 0x458239, 0x9cb93b,
  0xffd832, 0xff823b, 0xd1401f, 0x7c191a,
  0x310c1b, 0x833f34, 0xeb9c6e, 0xffdaac,
  0xffffe4, 0xbfc3c6, 0x6d8a8d, 0x293b49,
  0x041528, 0x033e5e, 0x1c92a7, 0x77d6c1,
  0xffe0dc, 0xff88a9, 0xc03b94, 0x601761
}

C.color_keys = {}
for k, c in pairs(hex_colors) do
  C.color_keys[#C.color_keys + 1] = k
end

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
