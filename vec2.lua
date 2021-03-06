local Class = require("class")
local V = Class:derive("Vec2")

function V:new(x, y)
  self.x = x or 0.0
  self.y = y or 0.0
end

function V:unit(angle)
  return V(math.cos(angle or 0.0), math.sin(angle or 0.0))
end

function V:inv_y()
  return V(self.x, -self.y)
end

function V:scale(s)
  return V(self.x * s, self.y * s)
end

function V:norm()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

function V:dist(v)
  return math.sqrt(math.pow(self.x - v.x, 2) + math.pow(self.y - v.y, 2))
end

function V:add(v1, v2)
  return V(v1.x + v2.x, v1.y + v2.y)
end

function V:sub(v1, v2)
  return V(v1.x - v2.x, v1.y - v2.y)
end

function V:divide(v1, divisor)
  assert(divisor ~= 0, "Error divisor must not be 0!")
  return V(v1.x / divisor, v1.y / divisor)
end

function V:multiply(v1, mult)
  return V(v1.x * mult, v1.y * mult)
end

function V:dot(other)
  return self.x * other.x + self.y * other.y
end

function V:mul(val)
  self.x = self.x * val
  self.y = self.y * val
  return self
end

function V:div(val)
  assert(val ~= 0, "Error val must not be 0!")
  self.x = self.x / val
  self.y = self.y / val
  return self
end

function V:normalize()
  local mag = self:norm()
  self.x = self.x / mag
  self.y = self.y / mag
  return self
end

-- Returns a vector that is the normal of this one (perpendicular)
function V:normal()
    return V(self.y, -self.x)
end

-- Rotates the Vector2 about the origin the given angle
-- Note: the last 2 parameters are optional and allow you to
-- add an offset to the results AFTER they have been rotated
-- Note: Modifies the object in-place
function V:rotate(angle, xoffset, yoffset)
  local nx = math.cos(angle) * self.x - math.sin(angle) * self.y + (xoffset or 0.0)
  local ny = math.sin(angle) * self.x + math.cos(angle) * self.y + (yoffset or 0.0)
  self.x = nx
  self.y = ny
end

function V:copy()
  return V(self.x, self.y)
end

return V
