require('opts.base')

local Pkgs = Base:new(Base)

function Pkgs:new (o)
  if o == nil then
    o = Base:new({})
  end
  -- o = o or Base:new(o)
  setmetatable(o, self)
  self.__index = self
  self.name = 'pkgs'
  return o
end

function Pkgs:run (...)
  local args = {...}
  args[1] = '~/.env/tools/scripts/pkgs'
  return table.concat(args,' '), ''
end

return Pkgs
