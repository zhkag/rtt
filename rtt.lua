local args = {...}

local string = require("string")
local config = loadfile(arg[0]:match("(.*[/\\])").."config.lua")()
local getopt = loadfile(arg[0]:match("(.*[/\\])").."getopt.lua")()

function getToolType()
  for k,v in pairs (config.toolType) do
    if os.execute("test -e " .. v["flag"]) then
        return k
    end
  end
end

function getSonOpts(cmd) -- 废弃 不采用这种方式  可以采用直接传入的方式
  -- getToolType().." --help"
  local logs = exec(cmd)
  local options = {}
  local opt = ''
  local pattern = "([ ])([-]+)([(%a|%-)]+)"
  local pattern2 = "([ ])([-]+)([(%a|%-)]+)([(,| |=)])([(%a| )])"
  for k,str in pairs(logs) do
    local sh = 0
    for x,y,z in string.gmatch(str, pattern) do
      if (y == '-')
      then
        sh = z
        opt = opt..z
      elseif(y == '--')
      then
        options[z] = sh
      end
    end
    for x,y,z,a,b in string.gmatch(str, pattern2) do
      if b:lower() >= 'a' and b:lower() <= 'z' then
        if (y == '-')
        then
          opt = opt..':'
        elseif(y == '--' and options[z] == 0)
        then
          options[z] = 1
        end
      end
    end
  end
  return opt,options
end

function getOpts(args)
  local sh_opts, long_opts = getSonOpts("scons --help")
  long_opts["menu"] = 0
  return getopt.get_opts (args, sh_opts, long_opts)
end

function transformArg(tool, arg)
  return config.toolType[tool][arg]
end

function transformArgs(tool, _args)
  local cmd = ''
  local short_opt, optarg = getOpts(_args)
  if(#_args == 0)
  then
    cmd = tool
  elseif (optarg == 1)
  then  -- 参数解析没成功
    if(transformArg(tool,"actions")[_args[1]] == true)
    then
      cmd = tool.." "..table.concat(_args,' ')
    -- else  rtt 特有命令可以放在这里
    end
  else -- 参数解析成功
    cmd = tool
    for k,v in pairs(short_opt) do
      local t
      if(transformArg(tool,k) == nil)
      then
        if(#k == 1)
        then
          t = '-'..k
        else
          t = '--'..k..((v == '') and '' or '=')
        end
      else
        t = transformArg(tool,k)..((v == '') and '' or ' ')
      end
      cmd = cmd..' '..t..v
    end
  end
  return cmd
end

function exec(cmd)
  local lines = {}
  local pipe = io.popen(cmd)
  for line in pipe:lines() do
    table.insert(lines,line)
  end
  return lines
end

function getGccTool()
  local log = exec("pwd")
  for k,tool in pairs(config.toolChains) do
    for k,v in pairs(tool.bsps) do
      if(string.find(log[1], string.gsub(v,'-','--')) ~= nil)
      then
        return tool.tool
      end
    end
  end
end

function main()
  local currentGccTool = getGccTool()
  local currentTool = getToolType()
  local cmd = transformArgs(currentTool,args)
  if(currentTool == 'scons' and currentGccTool ~= nil)
  then
    cmd = cmd..' --cc-prefix='..currentGccTool.prefix..' --cc-path='..currentGccTool.path
    -- 应该放在前面，可以让用户覆盖
  end
  print(cmd)
  os.execute(cmd)
end

main()

-- 采用命令配置子命令的方式  
-- 例如： rtt set --menu scons --menuconfig  表示可以使用 rtt --menu 调用 scons --menuconfig

