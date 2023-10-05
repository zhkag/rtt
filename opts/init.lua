-- 实现所有参数的解析
actions = {set=true,pkgs=true,scons=true}
opts = {}

function opts.main(...)
  local args = {...}
  local ret = ''
  if(#args == 0) then
    return {}
  end
  if(args[1]:sub (1, 1) == '-') then
    -- 这个要去判断 是不是 别名的 如果不是的话直接 返回参数 用默认的 命令
    -- 现在这种情况是通过 set 设置的无效
    return {...}
  end
  local action = args[1]
  if(actions[action] ~= nil) then
    local arg = require('opts.'..action)
    arg:setConfig()
    return arg:run(...)
  end
end

return opts
