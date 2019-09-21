local Class = require("class")
local Bezier = require("bezier")
local Color = require("color")
local Gaussian = require("gaussian")
local Vec2 = require("vec2")

local Fish = Class:derive("Fish")

function Fish:new(face_left, start_pos)
  self.happy = true
  self.face_left = face_left
  self.pos = start_pos or Vec2(0, 0)
  self.max_speed = 60.0 + math.random() * 50.0
  self.current_speed = self.max_speed
  self.is_stuck_to_bag = nil

  local length_mean = 40
  local length_var = 5
  self.length = Gaussian:gaussian(length_mean, length_var)
  local body_c_mean = 20
  local body_c_var = 4
  self.body_c_upper, self.body_c_lower = Gaussian:gaussian(body_c_mean, body_c_var)

  local dorsal_fin_tmin_mean = 0.3
  local dorsal_fin_tmin_var = 0.1
  local dorsal_fin_tmax_mean = 0.7
  local dorsal_fin_tmax_var = 0.1
  self.dorsal_fin_tmin = Fish:gaussian_t(dorsal_fin_tmin_mean, dorsal_fin_tmin_var)
  self.dorsal_fin_tmax = Fish:gaussian_t(dorsal_fin_tmax_mean, dorsal_fin_tmax_var)

  local adipose_fin_tmin_mean = 0.7
  local adipose_fin_tmin_var = 0.05
  local adipose_fin_tmax_mean = 0.85
  local adipose_fin_tmax_var = 0.05
  self.adipose_fin_tmin = Fish:gaussian_t(adipose_fin_tmin_mean, adipose_fin_tmin_var)
  self.adipose_fin_tmax = Fish:gaussian_t(adipose_fin_tmax_mean, adipose_fin_tmax_var)

  local anal_fin_tmin_mean = 0.6
  local anal_fin_tmin_var = 0.05
  local anal_fin_tmax_mean = 0.9
  local anal_fin_tmax_var = 0.05
  self.anal_fin_tmin = Fish:gaussian_t(anal_fin_tmin_mean, anal_fin_tmin_var)
  self.anal_fin_tmax = Fish:gaussian_t(anal_fin_tmax_mean, anal_fin_tmax_var)

  local tail_fin_t_upper_mean = 0.85
  local tail_fin_t_upper_var = 0.05
  local tail_fin_t_lower_mean = 0.85
  local tail_fin_t_lower_var = 0.05
  self.tail_fin_t_upper = Fish:gaussian_t(tail_fin_t_upper_mean, tail_fin_t_upper_var)
  self.tail_fin_t_lower = Fish:gaussian_t(tail_fin_t_lower_mean, tail_fin_t_lower_var)

  local tail_fin_c_mean = 15.0
  local tail_fin_c_var = 5.0
  self.tail_fin_c_upper, self.tail_fin_c_lower = Gaussian:gaussian(
      tail_fin_c_mean, tail_fin_c_var)

  local mouth_t_mean = 0.1
  local mouth_t_var = 0.05
  self.mouth_t = Fish:gaussian_t(mouth_t_mean, mouth_t_var)

  local mouth_t2_mean = 0.3
  local mouth_t2_var = 0.05
  self.mouth_t2 = Fish:gaussian_t(mouth_t2_mean, mouth_t2_var)

  local eye_radius_mean = 4.0
  local eye_radius_var = 1.0
  self.eye_radius = math.max(Gaussian:gaussian(eye_radius_mean, eye_radius_var), 1.0)

  local eye_pos_tmin_mean = 0.1
  local eye_pos_tmin_var = 0.1
  local eye_pos_tmax_mean = 0.3
  local eye_pos_tmax_var = 0.1
  self.eye_pos_tmin = Fish:gaussian_t(eye_pos_tmin_mean, eye_pos_tmin_var)
  self.eye_pos_tmax = Fish:gaussian_t(eye_pos_tmax_mean, eye_pos_tmax_var)

  self.body_color = Color:random_color()
  self.fin_color = Color:random_color()
  self.fin_color.a = 0.5
  self.eye_color = Color:random_color()
  self.eye_color.a = 0.8
  self.mouth_color = self.body_color:darken(0.5)
end

function Fish:update(t, dt)
  if (self.is_stuck_to_bag) then
    local delta = Vec2:sub(Vec2(self.pos.x + self:dir(self.length) / 3.0, self.pos.y), self.target)
    self.pos.x = self.pos.x - delta.x * dt * 3.0
    self.pos.y = self.pos.y - delta.y * dt * 3.0
  else
    if (self.current_speed < self.max_speed) then
      self.current_speed = math.min(self.current_speed + dt, self.max_speed)
    end
    self.pos.x = self.pos.x - self:dir(self.current_speed) * dt
  end
end

function Fish:draw()
  local body_vertices = {}
  local pos = self.pos
  local p1 = pos
  local p2 = Vec2(p1.x + self:dir(self.length), p1.y)
  local c1 = Vec2(p1.x, p1.y - self.body_c_upper)
  local c2 = Vec2(p2.x, p2.y - 10.0)
  local upper_curve = Bezier:curve(p1, c1, c2, p2)
  local upper_verts = upper_curve:render(3)
  for i=1, #upper_verts do
    body_vertices[#body_vertices + 1] = upper_verts[i]
  end

  p1 = pos
  p2 = Vec2(p1.x + self:dir(self.length), p1.y)
  c1 = Vec2(p1.x, p1.y + self.body_c_lower)
  c2 = Vec2(p2.x, p2.y + 10.0)
  local lower_curve = Bezier:curve(p1, c1, c2, p2)
  local lower_verts = lower_curve:render(3)
  for i=#lower_verts - 3, 3, -2 do
    body_vertices[#body_vertices + 1] = lower_verts[i]
    body_vertices[#body_vertices + 1] = lower_verts[i - 1]
  end

  -- Dorsal fin.
  local dorsal_vertices = {}
  p1 = Vec2(upper_curve:evaluate(self.dorsal_fin_tmin))
  c1 = Vec2(p1.x + self:dir(5.0), p1.y - 10.0)
  p2 = Vec2(upper_curve:evaluate(self.dorsal_fin_tmax))
  c2 = Vec2(p2.x + self:dir(5.0), p2.y - 10.0)
  local dorsal_curve = Bezier:curve(p1, c1, c2, p2)
  local dorsal_verts = dorsal_curve:render(3)
  for i=1, #dorsal_verts do
    dorsal_vertices[#dorsal_vertices + 1] = dorsal_verts[i]
  end

  -- Adipose fin.
  local adipose_vertices = {}
  p1 = Vec2(upper_curve:evaluate(self.adipose_fin_tmin))
  c1 = Vec2(p1.x + self:dir(2.0), p1.y - 5.0)
  p2 = Vec2(upper_curve:evaluate(self.adipose_fin_tmax))
  c2 = Vec2(p2.x + self:dir(2.0), p2.y - 5.0)
  local adipose_curve = Bezier:curve(p1, c1, c2, p2)
  local adipose_verts = adipose_curve:render(3)
  for i=1, #adipose_verts do
    adipose_vertices[#adipose_vertices + 1] = adipose_verts[i]
  end

  -- Anal fin.
  local anal_vertices = {}
  p1 = Vec2(lower_curve:evaluate(self.anal_fin_tmin))
  c1 = Vec2(p1.x - self:dir(2.0), p1.y + 5.0)
  p2 = Vec2(lower_curve:evaluate(self.anal_fin_tmax))
  c2 = Vec2(p2.x + self:dir(2.0), p2.y + 10.0)
  local anal_curve = Bezier:curve(p1, c1, c2, p2)
  local anal_verts = anal_curve:render(3)
  for i=1, #anal_verts do
    anal_vertices[#anal_vertices + 1] = anal_verts[i]
  end

  -- Caudal (tail) fin.
  local tail_vertices = {}
  p1 = Vec2(upper_curve:evaluate(self.tail_fin_t_upper))
  c1 = Vec2(p1.x + self:dir(self.tail_fin_c_lower), p1.y - self.tail_fin_c_upper)
  p2 = Vec2(lower_curve:evaluate(self.tail_fin_t_lower))
  c2 = Vec2(p2.x + self:dir(self.tail_fin_c_upper), p2.y + self.tail_fin_c_lower)
  local tail_curve = Bezier:curve(p1, c1, c2, p2)
  local tail_verts = tail_curve:render(3)
  for i=1, #tail_verts do
    tail_vertices[#tail_vertices + 1] = tail_verts[i]
  end

  -- Mouth.
  local mouth_vertices = {}
  p1 = Vec2(lower_curve:evaluate(self.mouth_t))
  p1.x = p1.x + self:dir(1.0)
  p2 = Vec2(lower_curve:evaluate(self.mouth_t2))
  p2.y = p1.y
  local delta_x = math.abs(p2.x - p1.x)
  if self.happy then
    c1 = Vec2(p1.x + self:dir(delta_x) / 2.0, p1.y + delta_x / 2.0)
  else
    c1 = Vec2(p1.x + self:dir(delta_x) / 2.0, p1.y - delta_x / 2.0)
  end

  -- c2 = Vec2(p2.x + 10.0, p2.y + 20.0)
  local mouth_curve = Bezier:curve_quadratic(p1, c1, p2)
  local mouth_verts = mouth_curve:render(3)
  for i=1, #mouth_verts do
    mouth_vertices[#mouth_vertices + 1] = mouth_verts[i]
  end

  love.graphics.setLineJoin("miter")
  love.graphics.setLineWidth(1.0)

  -- Draw fins.
  love.graphics.setColor(self.fin_color:rgba())
  triangles = love.math.triangulate(dorsal_vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end

  triangles = love.math.triangulate(adipose_vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end

  triangles = love.math.triangulate(anal_vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end

  triangles = love.math.triangulate(tail_vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end

  love.graphics.setColor(self.fin_color:lighten(0.3):rgba())
  love.graphics.line(dorsal_vertices)
  love.graphics.line(adipose_vertices)
  love.graphics.line(anal_vertices)
  love.graphics.line(tail_vertices)

  -- Draw body.
  love.graphics.setColor(self.body_color:rgba())
  local triangles = love.math.triangulate(body_vertices)
  for i, t in ipairs(triangles) do
    love.graphics.polygon('fill', t)
  end
  love.graphics.setColor(self.body_color:lighten(0.1):rgba())
  love.graphics.line(body_vertices)

  -- Draw mouth.
  love.graphics.setLineWidth(0.5)
  love.graphics.setColor(self.mouth_color:rgba())
  love.graphics.line(mouth_vertices)

  -- Draw eye.
  p1 = Vec2(upper_curve:evaluate(self.eye_pos_tmin))
  p2 = Vec2(upper_curve:evaluate(self.eye_pos_tmax))

  love.graphics.setColor(self.eye_color:lighten(0.3):rgba())
  love.graphics.circle("fill", p2.x, p1.y, self.eye_radius)
  love.graphics.setLineWidth(0.5)
  love.graphics.setColor(self.body_color:darken(0.2):rgba())
  love.graphics.circle("line", p2.x, p1.y, self.eye_radius)

  love.graphics.setColor(self.eye_color:darken(0.3):rgba())
  love.graphics.circle(
    "fill",
    p2.x - (self.eye_radius - 1.0) / 2.0,
    p1.y,
    self.eye_radius / 3.0
  )
end

function Fish:gaussian_t(mu, sigma)
  local y1, y2
  y1, y2 = Gaussian:gaussian(mu, sigma)
  return math.max(math.min(y1, 1.0), 0.0), math.max(math.min(y2, 1.0), 0.0)
end

function Fish:dir(v)
  return self.face_left and v or -v
end

return Fish
