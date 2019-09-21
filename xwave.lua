local Class = require("class")
local Vec2 = require('vec2')
local Wave = require('wave')
local XWave = Class:derive("XWave")

function XWave:new(poses, n_waves, lambda, width, height)
  self.debug = false
  self.n_waves = n_waves
  self.lambda = lambda
  self.width = width
  self.height = height

  self.waves = {}
  for i = 1, n_waves do
    local pix = math.min(i, #poses)
    self.waves[i] = Wave(
      poses[pix].f_r,
      poses[pix].f_t,
      poses[pix].f_cr,
      poses[pix].f_s,
      poses[pix].theta_t,
      poses[pix].theta_c,
      poses[pix].theta_r,
      poses[pix].crest_circle_radius,
      Vec2:add(poses[pix].crest_circle_center,
               Vec2((i - pix) * self.lambda, 0.0))
    )
  end
  self.left_x = self.waves[1].crest_circle_center.x
end

function XWave:update(t, dt)
  local theta_t = (math.pi / 2.0) + math.sin(t) * (math.pi / 2.1)

  local x = self.left_x
  local x_offset = math.fmod(t * self.waves[1].crest_circle_radius, self.lambda)
  for i = 1, self.n_waves do
    self.waves[i].crest_circle_center.x = x + x_offset
    x = x + self.lambda
  end

  for i = self.n_waves, 1, -1 do
    self.waves[i].theta_t = theta_t
    if i < self.n_waves then
      self.waves[i]:recalc(
          self.waves[i + 1].crest_circle_radius, self.waves[i + 1].crest_circle_center)
    else
      self.waves[i]:recalc()
    end
    -- waves[i].theta_c = math.min(math.pi - 0.1, waves[i].theta_c + dt / 2.0)
    -- waves[i].f_s = math.max(0.0, waves[i].f_s - dt / 2.0)
  end
end

function XWave:draw()
  -- local x_offset = 200.0
  -- local y_offset = 200.0
  --
  vertices = {self.waves[1].end_pos.x, self.waves[1].end_pos.y}
  self.waves[1]:connect(self.waves[2], vertices)
  for i = 2, self.n_waves - 1 do
    self.waves[i]:render(vertices)
    self.waves[i]:connect(self.waves[i + 1], vertices)
  end

  local last_x = vertices[#vertices - 1] + self.waves[self.n_waves].crest_circle_radius + 10.0
  local last_y = vertices[#vertices]
  local first_x = vertices[1] - self.waves[1].crest_circle_radius - 10.0
  local first_y = vertices[2]
  vertices[#vertices + 1] = last_x
  vertices[#vertices + 1] = last_y
  vertices[#vertices + 1] = last_x
  vertices[#vertices + 1] = 200
  vertices[#vertices + 1] = first_x
  vertices[#vertices + 1] = 200
  vertices[#vertices + 1] = first_x
  vertices[#vertices + 1] = first_y

  -- local v2 = {}
  -- for i, v in ipairs(vertices) do
  --   v2[#v2 + 1] = math.floor(v + 0.5)
  -- end

  -- for i, v in ipairs(vertices) do
  --   print(i, v)
  -- end

  love.graphics.line(vertices)
  local triangles = love.math.triangulate(vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end

  --for i = 1, 4 do
  --  vertices = {0.0, -1.0, 0.55, -1.0, 1.0, -0.55, 1.0, 0.0}
  --  curve = love.math.newBezierCurve(vertices)
  --  curve:scale(100.0)
  --  curve:translate(x_offset, y_offset)
  --  love.graphics.line(curve:render())
  --end


  --vertices = {1.0, 0.0, 1.0, 0.55, 0.55, 1.0, 0.0, 1.0}
  --curve = love.math.newBezierCurve(vertices)
  --curve:scale(100.0)
  --curve:translate(x_offset, y_offset)
  --love.graphics.line(curve:render())

  --vertices = {0.0, 1.0, -0.55, 1.0, -1.0, 0.55, -1.0, 0.0}
  --curve = love.math.newBezierCurve(vertices)
  --curve:scale(100.0)
  --curve:translate(x_offset, y_offset)
  --love.graphics.line(curve:render())

  --vertices = {-1.0, 0.0, -1.0, -0.55, -0.55, -1.0, 0.0, -1.0}
  --curve = love.math.newBezierCurve(vertices)
  --curve:scale(100.0)
  --curve:translate(x_offset, y_offset)
  --love.graphics.line(curve:render())
end

return XWave
