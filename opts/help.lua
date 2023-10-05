require("opts.base")

local Help = Base:new(Base)

function Help:new (o)
  if o == nil then
    o = Base:new({})
  end
  -- o = o or Base:new(o)
  setmetatable(o, self)
  self.__index = self
  self.name = 'help'
  return o
end

return Help
