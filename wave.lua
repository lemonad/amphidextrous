local Class = require("class")
local Vec2 = require("vec2")
local Wave = Class:derive("Wave")

local HALF_PI = math.pi / 2.0


function Wave:new(f_r, f_t, f_cr, f_s,
                  theta_t, theta_c, theta_r,
                  crest_circle_radius, crest_circle_center)
  self.debug = false

  self.f_r = f_r
  self.f_t = f_t
  self.f_cr = f_cr
  self.f_s = f_s
  self.theta_t = theta_t
  self.theta_c = theta_c
  self.theta_r = theta_r
  self.crest_circle_radius = crest_circle_radius
  self.crest_circle_center = crest_circle_center
end

function Wave:recalc(next_crest_circle_radius, next_crest_circle_center)
  local next_center = next_crest_circle_center or Vec2(
          self.crest_circle_center.x + self.crest_circle_radius * 5.0,
          self.crest_circle_center.y
        )
  local next_radius = next_crest_circle_radius or self.crest_circle_radius

  self.start_pos = Vec2(self.crest_circle_center.x,
                        self.crest_circle_center.y - self.crest_circle_radius)
  local x1 = self.crest_circle_center.x + self.crest_circle_radius
  local x2 = next_center.x - next_radius
  self.trough_circle_center = Vec2(x1 + (x2 - x1) / 2.0, self.crest_circle_center.y)
  local x_delta = self.trough_circle_center.x - (self.crest_circle_center.x + 10.0)
  self.end_pos = Vec2(self.crest_circle_center.x + 10.0 + (1.0 - (self.theta_t / math.pi)) * x_delta,
                      self.crest_circle_center.y + self.crest_circle_radius)
end

function Wave:render(vertices)
  if self.debug then
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle('fill', self.start_pos.x - 2, self.start_pos.y - 2, 4, 4)
    love.graphics.rectangle('fill', self.end_pos.x - 2, self.end_pos.y - 2, 4, 4)
  end

  local pos
  local radius
  pos, radius, angle = self:draw_windup(vertices)
  self:draw_unwind(pos, radius, angle, vertices)

  -- love.graphics.setColor(1, 1, 1, 1)
  -- love.graphics.line(vertices:render())
end

function Wave:draw_windup(vertices)
  local angle = 0
  local c = self.theta_c
  local radius = (0.05 + 0.95 * self.f_r) * self.crest_circle_radius
  local pos = self.start_pos
  while (c > 0) do
    local d = math.min(c, HALF_PI)
    local h = Vec2:unit(angle + HALF_PI):scale(radius):inv_y()
    local origin = Vec2:sub(pos, h)
    local next_pos = Vec2:add(origin, Vec2:unit(angle + HALF_PI- d):scale(radius):inv_y())

    local f = (4.0 / 3.0) * math.tan(d / 4.0)
    local c1 = Vec2(
      pos.x + f * math.cos(angle) * radius,
      pos.y - f * math.sin(angle) * radius)
    local c2 = Vec2(
      next_pos.x + f * math.cos(angle - d) * radius,
      next_pos.y - f * math.sin(angle - d) * radius)

    local bverts = self:bezier_vertices(pos, c1, c2, next_pos)
    -- local first_ix = 1
    for i=3, #bverts do
      vertices[#vertices + 1] = bverts[i]
    end

    pos = next_pos
    angle = angle - d
    c = c - d
    radius = radius * (0.6 + 0.4 * self.f_s)
  end

  return pos, radius, angle
end

function Wave:draw_unwind(pos, radius, angle, vertices)
  -- f_t == 0.0:
  -- radius = math.min(self.crest_circle_radius, radius * 1.0 / (0.6 + 0.4 * self.f_s))
  -- f_t == 1.0:
  --
  c = self.theta_c
  while (c > 0) do
    local d = math.min(c, HALF_PI)
    local h = Vec2:unit(angle + HALF_PI):scale(radius):inv_y()
    local origin = Vec2:sub(pos, h)
    local next_pos = Vec2:add(origin, Vec2:unit(angle + HALF_PI + d):scale(radius):inv_y())

    local f = (4.0 / 3.0) * math.tan(d / 4.0)
    local c1 = Vec2(
      pos.x - f * math.cos(angle) * radius,
      pos.y + f * math.sin(angle) * radius)
    local c2 = Vec2(
      next_pos.x + f * math.cos(angle + d) * radius,
      next_pos.y - f * math.sin(angle + d) * radius)

    local bverts = self:bezier_vertices(pos, c1, c2, next_pos)
    for i=3, #bverts do
      vertices[#vertices + 1] = bverts[i]
    end

    pos = next_pos
    angle = angle + d
    c = c - d
    -- f_t == 0.0:
    -- radius = math.min(self.crest_circle_radius, radius * 1.0 / (0.6 + 0.4 * self.f_s))
    -- f_t == 1.0:
    radius = math.min(self.crest_circle_radius, radius * (1.0 / 0.2))
  end

  -- local delta = Vec2:sub(self.end_pos, pos)
  -- local r1 = (delta.y / 2.0) - (delta.x / 2.0)
  -- local r2 = (delta.y / 2.0) + (delta.x / 2.0)

  -- local next_pos = Vec2(pos.x - r1, pos.y + r1)
  -- local f = (4.0 / 3.0) * math.tan(HALF_PI / 4.0)
  -- local c1 = Vec2(pos.x - f * r1, pos.y)
  -- local c2 = Vec2(next_pos.x, next_pos.y - f * r2)
  -- Wave:draw_bezier(pos, c1, c2, next_pos)

  -- pos = next_pos
  -- next_pos = Vec2(pos.x + r2, pos.y + r2)
  -- c1 = Vec2(pos.x, pos.y + f * r2)
  -- c2 = Vec2(next_pos.x - f * r2, next_pos.y)
  -- Wave:draw_bezier(pos, c1, c2, next_pos)

  angle = angle - self.theta_t
  local r = (self.end_pos.y - pos.y) / 2.0
  local h = Vec2:unit(angle):scale(r):inv_y()
  c1 = Vec2(pos.x + h.x, pos.y + h.y)
  c2 = Vec2(self.end_pos.x - r, self.end_pos.y)
  local bverts = self:bezier_vertices(pos, c1, c2, self.end_pos)
  for i=3, #bverts do
    vertices[#vertices + 1] = bverts[i]
  end
end

function Wave:connect(next, vertices)
  self:connect_with_point(next.start_pos, vertices)
end

function Wave:connect_with_point(pos, vertices)
  local delta, left_pos, right_pos
  if self.end_pos.x < pos.x then
    -- connect end position with point on the right
    left = self.end_pos
    right = pos
  else
    -- connect point on the left with start position
    left = pos
    right = self.start_pos
  end

  delta = Vec2:sub(right, left)
  local bverts = self:bezier_vertices(
      left,
      Vec2(left.x + delta.x / 3.0, left.y),
      Vec2(right.x - delta.x / 3.0, right.y),
      right
  )

  -- local bverts = self:bezier_vertices(self.end_pos,
  --     Vec2(self.end_pos.x + delta.x / 3.0, self.end_pos.y),
  --     Vec2(next.start_pos.x - delta.x / 3.0, next.start_pos.y),
  --     next.start_pos
  -- )

  for i=3, #bverts do
    vertices[#vertices + 1] = bverts[i]
  end
end

function Wave:bezier_vertices(p1, c1, c2, p2)
  local vertices = {
    -- start position
    p1.x, p1.y,
    -- first control point
    c1.x, c1.y,
    -- second control point
    c2.x, c2.y,
    -- end point
    p2.x, p2.y
  }
  -- print(table.concat(vertices, ", "))

  if self.debug then
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.line(vertices[1], vertices[2], vertices[3], vertices[4])
    love.graphics.rectangle('fill', vertices[3] - 2, vertices[4] - 2, 5, 5)

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.line(vertices[5], vertices[6], vertices[7], vertices[8])
    love.graphics.rectangle('fill', vertices[5] - 2, vertices[6] - 2, 5, 5)
  end

  -- love.graphics.setColor(1, 1, 1, 1)
  local curve = love.math.newBezierCurve(vertices)
  -- return curve:renderSegment(0.0, 1.0, 1)
  return curve:render(3)
  -- love.graphics.line(curve:render())
end

return Wave
