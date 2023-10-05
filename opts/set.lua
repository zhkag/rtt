require("opts.base")

local Set = Base:new(Base)

function Set:new (o)
  if o == nil then
    o = Base:new({})
  end
  -- o = o or Base:new(o)
  setmetatable(o, self)
  self.__index = self
  self.name = 'set'
  return o
end

function Set:setConfig(config)
  if config == nil then
    config = require('config'):new({},require('config.path').opts)
  end
  self.config = config
end

function Set:run (...)
  local args = {...}
  local arg = {}
  local parameter = ''
  for k,v in string.gmatch(args[2], '([-]+)([(%a|%-)]+)') do
    parameter = v
  end
  if(string.sub(args[2], -1) == '=') then
    arg['parameter'] = true
    arg['arg'] = string.sub(parameter, 1, -1)
  else
    arg['arg'] = parameter
  end
  local argAlias = {}
  local aliasStart = 2
  if(#args > 3) then
    -- for k,v in pairs(config.toolType) do
    --   if(k == args[3]) then
    --     arg['tool'] = k
    --     aliasStart = 3
    --   end
    -- end
  end
  for i, v in ipairs(args) do
    if (i > aliasStart) then
      table.insert(argAlias, v)
    end
  end
  arg['alias'] = table.concat(argAlias,' ')
  local alias = self.config:load()
  for k,v in pairs(alias) do
    if(v['arg'] == arg['arg']) then
      table.remove(alias,k)
    end
  end
  if(arg['alias'] ~= '') then
    alias[#(alias) + 1] = arg
  end
  self.config:write(alias)
  return {},''
end

return Set