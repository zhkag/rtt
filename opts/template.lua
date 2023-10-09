require("opts.base")

local Template = Base:new(Base)

function Template:new (o)
  if not o then
    o = Base:new({})
  end
  -- o = o or Base:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Template:setName(name)
  self.name = name
end

return Template
