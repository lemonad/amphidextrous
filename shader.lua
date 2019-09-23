local Class = require("class")
local Color = require("color")
local Vec2 = require("vec2")

local S = Class:derive("Shader")

function S:new()
  local wave_color = Color:color_from_index(27)
  local sand_color = Color:color_from_index(24)

  self.bottom_color = Color:color_from_index(26):lighten(0.1)
  self.top_color = Color:color_from_index(30)
  self.line_color = wave_color:darken(0.0)
  self.under_color = sand_color

  local data = love.image.newImageData(800, 10)
  for i = 0, 9, 1 do
      local handdrawn_data = {}
      for line in love.filesystem.lines("data/handdrawn-data" .. i .. ".txt") do
          handdrawn_data[#handdrawn_data+1] = tonumber(line)
      end

      -- print(#handdrawn_data)
      for j=0, #handdrawn_data-1 do
          local v = 0.5 + handdrawn_data[j + 1] / 6.0
          data:setPixel(j, i, 0, v, 0, 1.0)
      end
  end
  self.wave = love.graphics.newCanvas(800, 530)
  self.shader = love.graphics.newShader("glsl/wave.glsl")
  self.shader:send("handdrawn", love.graphics.newImage(data))

end

function S:update(t, dt)
end

function S:draw(wave_y)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.wave, 0, wave_y, 0)
  love.graphics.setBlendMode("alpha")
end

function S:draw_on_canvas()
  love.graphics.setCanvas(self.wave)
  love.graphics.clear()
  self.shader:send("wave_seed", {10.0, 10000.0})
  self.shader:send("bottom_color", self.bottom_color:rgba())
  self.shader:send("top_color", self.top_color:rgba(0.0))
  self.shader:send("line_color", self.line_color:rgba())
  self.shader:send("under_color", self.under_color:rgba())
  love.graphics.setShader(self.shader)
  love.graphics.rectangle('fill', 0, 0, 800, 530)
  love.graphics.setShader()
  love.graphics.setCanvas()
end

return S
