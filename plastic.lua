local Class = require("class")
local Bezier = require("bezier")
local Color = require("color")
local Gaussian = require("gaussian")
local Vec2 = require("vec2")

local Plastic = Class:derive("Plastic")

function Plastic:new(center_pos)
  self.angle = math.random() * math.pi
  self.scale = 40.0
  self.center_pos = center_pos
  self.upper_left_corner = Vec2(-0.5, -0.5)
  self.upper_right_corner = Vec2(0.5, -0.5)
  self.lower_left_corner = Vec2(-0.5, 0.5)
  self.lower_right_corner = Vec2(0.5, 0.5)

  self.max_speed = 25.0
  self.current_speed = self.max_speed
  self.drifting_left = math.random() > 0.5
  self.is_stuck_to_fish = nil

  self.cs_factors = {}
  self.cs = {}
  for i = 1, 16 do
    self.cs_factors[i] = math.random() * math.pi
    self.cs[i] = 0.0
  end

  self.color = Color:random_color()
  self.color.a = 0.4
end

function Plastic:update(t, dt)
  self.center_pos.y = self.center_pos.y - self.current_speed * dt
  self.center_pos.x = self.center_pos.x + self:dir(10.0) * dt

  self.angle = self.angle + dt / 24.0
  self.mult = dt
  self.upper_left_corner = Vec2(
    -0.5 + math.sin(t + 0.35) * self.mult,
    -0.5 + math.sin(t + 0.6) * self.mult
  )
  self.upper_right_corner = Vec2(
    0.5 + math.sin(t + 0.2) * self.mult,
    -0.5 + math.sin(t + 0.9) * self.mult
  )
  self.lower_left_corner = Vec2(
    -0.5 + math.sin(t + 0.1) * self.mult,
    0.5 + math.sin(t + 0.55) * self.mult
  )
  self.lower_right_corner = Vec2(
    0.5 + math.sin(t + 0.31) * self.mult,
    0.5 + math.sin(t + 0.67) * self.mult
  )

  self.upper_left_corner:rotate(self.angle)
  self.upper_right_corner:rotate(self.angle)
  self.lower_left_corner:rotate(self.angle)
  self.lower_right_corner:rotate(self.angle)

  for i = 1, 16 do
    self.cs[i] = 0.0 + math.sin(self.cs_factors[i] * t + i) * 10.0
  end
end

function Plastic:draw()
  local ul = Vec2(
    self.center_pos.x + self.upper_left_corner.x * self.scale,
    self.center_pos.y + self.upper_left_corner.y * self.scale
  )
  local ulc1 = Vec2(ul.x - self.cs[1], ul.y - self.cs[2])
  local ulc2 = Vec2(ul.x - self.cs[9], ul.y - self.cs[10])
  local ll = Vec2(
    self.center_pos.x + self.lower_left_corner.x * self.scale,
    self.center_pos.y + self.lower_left_corner.y * self.scale
  )
  local llc1 = Vec2(ll.x - self.cs[3], ll.y + self.cs[4])
  local llc2 = Vec2(ll.x - self.cs[11], ll.y + self.cs[12])
  local lr = Vec2(
    self.center_pos.x + self.lower_right_corner.x * self.scale,
    self.center_pos.y + self.lower_right_corner.y * self.scale
  )
  local lrc1 = Vec2(lr.x + self.cs[5], lr.y + self.cs[6])
  local lrc2 = Vec2(lr.x + self.cs[13], lr.y + self.cs[14])
  local ur = Vec2(
    self.center_pos.x + self.upper_right_corner.x * self.scale,
    self.center_pos.y + self.upper_right_corner.y * self.scale
  )
  local urc1 = Vec2(ur.x + self.cs[7], ur.y - self.cs[8])
  local urc2 = Vec2(ur.x + self.cs[15], ur.y - self.cs[16])

  local vertices = {}
  local curve, verts
  curve = Bezier:curve(ul, ulc1, llc1, ll)
  verts = curve:render(2)
  for i=3, #verts - 2, 2 do
    local delta = Vec2:sub(
      Vec2(verts[i], verts[i + 1]),
      Vec2(vertices[#vertices - 1], vertices[#vertices])
    )
    if (delta:norm() > 2.0) then
      vertices[#vertices + 1] = verts[i]
      vertices[#vertices + 1] = verts[i + 1]
    end
  end

  curve = Bezier:curve(ll, llc1, lrc1, lr)
  verts = curve:render(2)
  for i=3, #verts - 2, 2 do
    local delta = Vec2:sub(
      Vec2(verts[i], verts[i + 1]),
      Vec2(vertices[#vertices - 1], vertices[#vertices])
    )
    if (delta:norm() > 2.0) then
      vertices[#vertices + 1] = verts[i]
      vertices[#vertices + 1] = verts[i + 1]
    end
  end

  curve = Bezier:curve(lr, lrc1, urc1, ur)
  verts = curve:render(2)
  for i=3, #verts - 2, 2 do
    local delta = Vec2:sub(
      Vec2(verts[i], verts[i + 1]),
      Vec2(vertices[#vertices - 1], vertices[#vertices])
    )
    if (delta:norm() > 2.0) then
      vertices[#vertices + 1] = verts[i]
      vertices[#vertices + 1] = verts[i + 1]
    end
  end

  curve = Bezier:curve(ur, urc1, ulc1, ul)
  verts = curve:render(2)
  for i=3, #verts - 2, 2 do
    local delta = Vec2:sub(
      Vec2(verts[i], verts[i + 1]),
      Vec2(vertices[#vertices - 1], vertices[#vertices])
    )
    if (delta:norm() > 2.0) then
      vertices[#vertices + 1] = verts[i]
      vertices[#vertices + 1] = verts[i + 1]
    end
  end
  if (Vec2:sub(
    Vec2(vertices[1], vertices[2]),
    Vec2(vertices[#vertices - 1], vertices[#vertices])
  ):norm() < 1.0) then
    vertices[#vertices] = nil
    vertices[#vertices] = nil
  end

  -- love.graphics.setLineJoin("none")
  -- love.graphics.setLineStyle("smooth")
  love.graphics.setColor(self.color:lighten(0.0):rgba())
  local triangles = love.math.triangulate(vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end

  love.graphics.setColor(self.color:rgba())
  love.graphics.line(vertices)
  vertices[#vertices + 1] = vertices[1]
  vertices[#vertices + 1] = vertices[2]
end

function Plastic:dir(v)
  return self.drifting_left and v or -v
end

return Plastic
