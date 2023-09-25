config = {}

package.cpath = arg[0]:match("(.*[/\\])")..'?.so;'
local cjson = require('cjson')
local file_path = arg[0]:match("(.*[/\\])").."config.json"

local function file_load(filename)
  local file
  if filename == nil then
    file = io.stdin
  else
    local err
    file, err = io.open(filename, "rb")
    if file == nil then
      error(("Unable to read '%s': %s"):format(filename, err))
    end
  end
  local data = file:read("*a")

  if filename ~= nil then
    file:close()
  end

  if data == nil then
    error("Failed to read " .. filename)
  end

  return data
end

local function file_save(filename, data)
  local file
  if filename == nil then
    file = io.stdout
  else
    local err
    file, err = io.open(filename, "wb")
    if file == nil then
      error(("Unable to write '%s': %s"):format(filename, err))
    end
  end
  file:write(data)
  if filename ~= nil then
    file:close()
  end
end

function config.load()
  local json_text = file_load(file_path)
  local data = cjson.decode(json_text)
  for k,v in pairs(data) do 
    config.args.alias[k] = v
  end
end

function config.write()
  local json_str = cjson.encode(config.args.alias)
  file_save(file_path,json_str)
end


local xmakeActions = {  create=true,
                    "i","install",
                    "c","clean",
                    "r","run",
                    "q","require",
                    "b","build",
                    "g","global",
                    "u","uninstall",
                        "update",
                    f=true,"config",
                    "p","package",
                        "service"}
local sconsArgs = {flag="SConstruct",menu="--menuconfig"}
local xmakeArgs = {flag="xmake.lua",menu="f --menu",actions=xmakeActions}

function setArgs(args)
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
  for i, v in ipairs(args) do
    if (i > 2) then
      table.insert(argAlias, v)
    end
  end
  arg['alias'] = table.concat(argAlias,' ')
  config.load()
  for k,v in pairs(config.args.alias) do
    if(v['arg'] == arg['arg']) then
      table.remove(config.args.alias,k)
    end
  end
  if(arg['alias'] ~= '') then
    config.args.alias[#(config.args.alias) + 1] = arg
  end
  config.write()
  return true
end

config.toolType = {scons=sconsArgs,xmake=xmakeArgs}

local armTool = {prefix="arm-none-eabi-",path="/opt/rt-thread/tools/gnu_gcc/gcc-arm-none-eabi/bin"}
local riscv64SmartTool = {prefix="riscv64-unknown-linux-musl-",path="/opt/rt-thread/tools/gnu_gcc/riscv64-linux-musleabi/bin"}
local armSmartTool = {prefix="arm-linux-musleabi-",path="/opt/rt-thread/tools/gnu_gcc/arm-linux-musleabi/bin"}
local aarch64SmartTool = {prefix="aarch64-linux-musleabi-",path="/opt/rt-thread/tools/gnu_gcc/aarch64-linux-musleabi/bin"}

local riscv64Smart={tool=riscv64SmartTool,bsps={"qemu-virt64-riscv"}}
local armSmart={tool=armSmartTool,bsps={"qemu-vexpress-a9"}}
local aarch64Smart={tool=aarch64SmartTool,bsps={"qemu-virt64-aarch64"}}
local arm={tool=armTool,bsps={"stm32"}}

config.toolChains = {arm, armSmart, riscv64Smart, aarch64Smart}

config.args = {fun={{arg='set',fun=setArgs}},alias={}}

return config