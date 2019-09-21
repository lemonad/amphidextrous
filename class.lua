local Class = {}
Class.__index = Class

function Class:new()
end

function Class:derive(type)
    local klass = {}
    klass["__call"] = Class.__call
    klass.type = type
    klass.__index = klass
    klass.super = self
    setmetatable(klass, self)
    return klass
end

function Class:__call(...)
    local instance = setmetatable({}, self)
    instance:new(...)
    return instance
end

function Class:get_type()
    return self.type
end

return Class
