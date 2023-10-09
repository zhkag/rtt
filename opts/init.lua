-- 实现所有参数的解析
require("tools")
require("config.path")

local actions = {set=true}
opts = {}

function opts.main(...)
  local args = {...}
  local ret = ''
  if #args == 0 then
    return {}
  end
  if args[1]:sub (1, 1) == '-' then
    -- 这个要去判断 是不是 别名的 如果不是的话直接 返回参数 用默认的 命令
    -- 现在这种情况是通过 set 设置的无效
    return {...}
  end
  local action = args[1]
  for k,v in pairs(require("config.tools")) do
    actions[k] = v
  end
  if actions[action] then
    local arg = {}
    if(tools.exectest(path.rtt..'/opts/'..action..'.lua')) then
      arg = require('opts.'..action)
    else
      require('opts.base')
      arg = Base:new(Base,action)
    end
    arg:setConfig()
    return arg:run(...)
  end
  print('Parameter not successfully parsed!')
  return {},''
end

return opts
