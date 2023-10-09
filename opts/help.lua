require("opts.base")

local Help = Base:new(Base,'help')

function Help:new (o)
  if not o then
    o = Base:new({})
  end
  -- o = o or Base:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end

return Help
