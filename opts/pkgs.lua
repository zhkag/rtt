require('opts.base')

local Pkgs = Base:new(Base,'pkgs')

function Pkgs:new (o)
  if not o then
    o = Base:new({})
  end
  -- o = o or Base:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pkgs:run (...)
  local args = {...}
  args[1] = '~/.env/tools/scripts/pkgs'
  return args, ''
end

return Pkgs
