local Class = require("class")
local Color = require("color")
local Vec2 = require("vec2")

local S = Class:derive("Submarine")

function S:new(pos)
  self.arms = {
    {
      pos = Vec2(80, 0),
      length1 = 200,
      length2 = 170,
      angle1 = 0,
      angle2 = 0,
      target = Vec2(600, 200),
      current_pos = Vec2(300, 300)
    },
    {
      pos = Vec2(-80, 0),
      length1 = 200,
      length2 = 170,
      angle1 = math.pi,
      angle2 = 0,
      target = Vec2(200, 200),
      current_pos = Vec2(300, 300)
    }
  }
  self.current_arm = 1

  self.pos = pos
end

function S:update(t, dt)
  for i = 1, #self.arms do
    local arm = self.arms[i]

    local l1 = arm.length1
    local l2 = arm.length2
    local a1 = arm.angle1
    local a2 = arm.angle2

    local pos = Vec2:sub(arm.target, Vec2:add(self.pos, arm.pos))
    if pos:norm() < (l1 + l2 - 1) then
      local x = pos.x
      local y = pos.y
      local beta = math.acos((x * x + y * y - l1 * l1 - l2 * l2) / (2 * l1 * l2))
      local alpha = math.atan2(y, x) - math.atan2(l2 * math.sin(beta), l1 + l2 * math.cos(beta))

      local diff_angle1 = a1 - alpha
      local diff_angle2 = a2 - beta

      while diff_angle1 < math.pi do
        diff_angle1 = diff_angle1 + math.pi * 2
      end
      while diff_angle1 > math.pi do
        diff_angle1 = diff_angle1 - math.pi * 2
      end

      while diff_angle2 < math.pi do
        diff_angle2 = diff_angle2 + math.pi * 2
      end
      while diff_angle2 > math.pi do
        diff_angle2 = diff_angle2 - math.pi * 2
      end

      local delta = dt * 2.0
      if math.abs(diff_angle1) < delta then
        a1 = alpha
      elseif diff_angle1 < 0 then
        a1 = a1 + delta
      else
        a1 = a1 - delta
      end

      if math.abs(diff_angle2) < delta then
        a2 = beta
      elseif diff_angle2 < 0 then
        a2 = a2 + delta
      else
        a2 = a2 - delta
      end

      arm.angle1 = a1
      arm.angle2 = a2
      arm.current_pos = Vec2(
        self.pos.x + arm.pos.x + math.cos(a1) * l1 + math.cos(a1 + a2) * l2,
        self.pos.y + arm.pos.y + math.sin(a1) * l1 + math.sin(a1 + a2) * l2
      )
    end
  end
end

function S:draw()
  love.graphics.origin()
  love.graphics.translate(self.pos.x, self.pos.y)

  for i = 1, #self.arms do
    love.graphics.setColor(Color:color_from_index(13):rgba())
    local arm = self.arms[i]
    love.graphics.push()
    love.graphics.translate(arm.pos.x, arm.pos.y)
    love.graphics.rotate(arm.angle1)
    love.graphics.rectangle("fill", 0, 0, arm.length1, 10)

    love.graphics.translate(arm.length1, 0)
    love.graphics.rotate(arm.angle2)
    love.graphics.rectangle("fill", 0, 0, arm.length2, 10)

    love.graphics.translate(arm.length2, 0)
    love.graphics.circle("fill", 0, 0, 20)
    love.graphics.pop()

    if i == self.current_arm then
      love.graphics.setColor(Color:color_from_index(31):rgba(0.5))
    else
      love.graphics.setColor(Color:color_from_index(27):rgba(0.3))
    end
    love.graphics.circle("fill", arm.current_pos.x - self.pos.x, arm.current_pos.y - self.pos.y, 15)
  end

  -- cockpit
  love.graphics.setColor(Color:color_from_index(27):rgba())
  love.graphics.arc("fill", 0, -39, 30, 0, -math.pi)

  --  sub
  love.graphics.setColor(Color:color_from_index(13):rgba())
  love.graphics.arc("fill", -50, 0, 40, math.pi / 2.0, 3 * math.pi / 2.0)
  love.graphics.rectangle("fill", -50, -40, 100, 80)
  love.graphics.arc("fill", 50, 0, 40, math.pi / 2.0, - math.pi / 2.0)

  love.graphics.setColor(Color:color_from_index(13):darken(0.2):rgba())
  love.graphics.circle("fill", -50, 0, 13)
  love.graphics.circle("fill", 0, 0, 13)
  love.graphics.circle("fill", 50, 0, 13)

end

function S:set_target(x, y)
  local min_dist = 10000
  local min_index = 0

  for i = 1, #self.arms do
    local d = self.arms[i].current_pos:dist(Vec2(x, y))
    if d < min_dist then
      min_dist = d
      min_index = i
    end
  end
  self.arms[min_index].target = Vec2(x, y)
end

return S
