local Class = require("class")
local Vec2 = require("vec2")

local B = Class:derive("Bezier")

DEBUG = false

function B:curve_quadratic(p1, c1, p2)
  local vertices = {
    -- start position
    p1.x, p1.y,
    -- control point
    c1.x, c1.y,
    -- end point
    p2.x, p2.y
  }
  return love.math.newBezierCurve(vertices)
end

function B:curve(p1, c1, c2, p2)
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

  if DEBUG then
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.line(vertices[1], vertices[2], vertices[3], vertices[4])
    love.graphics.rectangle('fill', vertices[3] - 2, vertices[4] - 2, 5, 5)

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.line(vertices[5], vertices[6], vertices[7], vertices[8])
    love.graphics.rectangle('fill', vertices[5] - 2, vertices[6] - 2, 5, 5)
  end

  return love.math.newBezierCurve(vertices)
end

return B
