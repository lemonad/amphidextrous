local Class = require("class")
local Vec2 = require("vec2")

local L = Class:derive("LSystem")

function L:new(axiom, productions, finals, root_pos)
  self.axiom = axiom
  self.productions = productions
  self.finals = finals
  self.string = axiom
  self.root_pos = root_pos or Vec2(0, 0)
  self.iterations = 0
end

function L:iterate(n)
  for i = 1, (n or 1) do
    local result = ""
    for i = 1, #self.string do
      local new_symbol
      local symbol = self.string:sub(i, i)
      local prod = self.productions[symbol]
      if prod ~= nil then
        if type(prod) == "string" then
          new_symbol = prod
        else
          new_symbol = prod()
        end
      end
      result = result .. (new_symbol or symbol)
    end
    self.string = result
    self.iterations = self.iterations + 1
  end
end

function L:draw()
  love.graphics.translate(self.root_pos.x, self.root_pos.y)

  for i = 1, #self.string do
    local symbol = self.string:sub(i, i)
    if self.finals[symbol] ~= nil then
      self.finals[symbol](i, symbol, self.iterations)
    end
  end
end

return L
