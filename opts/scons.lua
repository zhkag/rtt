require('opts.base')

local Scons = Base:new(Base)

function Scons:new (o)
  if not o then
    o = Base:new({})
  end
  setmetatable(o, self)
  self.__index = self
  self.name = 'scons'
  return o
end

function Scons:run (...)
  return {...}, ''
end

return Scons
