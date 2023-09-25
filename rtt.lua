local args = {...}
package.path = arg[0]:match("(.*[/\\])")..'?.lua;'..package.path

local string = require("string")
local config = require("config")
local getopt = require("getopt")

function getToolType()
  for k,v in pairs (config.toolType) do
    if os.execute("test -e " .. v["flag"]) then
        return k
    end
  end
end

function getOpts(args)
  local sh_opts = ''
  local long_opts = {}
  for k,v in pairs(config.args.alias) do
    if (#(v.arg) == 1) then
      sh_opts = sh_opts..v.arg..((v.parameter ~= true) and '' or ':')
    else
      long_opts[v.arg] = (v.parameter ~= true) and 0 or 1
    end
  end
  return getopt.get_opts (args, sh_opts, long_opts)
end

function transformArg(tool, arg)
  return config.toolType[tool][arg]
end

function transformArgs(_args)
  local cmd = ''
  if(#args ~= 0)
  then
    for k,v in pairs(config.args.fun)do
      if(v['arg'] == args[1] and type(v['fun']) == 'function') then
        return v['fun'](args)
      end
    end
  end
  
  local short_opt, optarg = getOpts(_args)

  for k,v in pairs(short_opt) do
    local t
    for i,j in pairs(config.args.alias) do
      if(j.arg == k and type(j.alias) == 'string') then
        t = j.alias
      end
    end
    cmd = cmd..' '..t..v
  end
  if(optarg == 1) then
    cmd = table.concat(_args,' ')
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
  config.load()
  local cmd = transformArgs(args)
  if (cmd == true) then
    return ''
  end

  local env = 'export RTT_CC_PREFIX='..currentGccTool.prefix..' && export RTT_EXEC_PATH='..currentGccTool.path..' && '
  if(currentTool == 'scons' and currentGccTool ~= nil) then
    cmd = env..currentTool..cmd
  else
    cmd = currentTool..cmd
  end
  print(cmd)
  os.execute(cmd)
end

main()

-- 采用命令配置子命令的方式  
-- 例如： rtt set --menu scons --menuconfig  表示可以使用 rtt --menu 调用 scons --menuconfig

