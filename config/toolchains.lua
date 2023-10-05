local tools = {}

tools.arm = {
    prefix="arm-none-eabi-",
    path="/opt/rt-thread/tools/gnu_gcc/gcc-arm-none-eabi/bin",
    bsps={"stm32"}
}
tools.riscv64Musl = {
    prefix="riscv64-unknown-linux-musl-",
    path="/opt/rt-thread/tools/gnu_gcc/riscv64-linux-musleabi/bin",
    bsps={"qemu-virt64-riscv"}
}
tools.armMusl = {
    prefix="arm-linux-musleabi-",
    path="/opt/rt-thread/tools/gnu_gcc/arm-linux-musleabi/bin",
    bsps={"qemu-vexpress-a9"}
}
tools.aarch64Musl = {
    prefix="aarch64-linux-musleabi-",
    path="/opt/rt-thread/tools/gnu_gcc/aarch64-linux-musleabi/bin",
    bsps={"qemu-virt64-aarch64"}
}

local function exec(cmd)
  local lines = {}
  local pipe = io.popen(cmd)
  for line in pipe:lines() do
    table.insert(lines,line)
  end
  return lines
end

local function getGccTool()
  local log = exec("pwd")
  for k,tool in pairs(tools) do
    for k,v in pairs(tool.bsps) do
      if(string.find(log[1], string.gsub(v,'-','--')) ~= nil)
      then
        return tool
      end
    end
  end
end

function setEnv()
  local tool = getGccTool()
  return 'export RTT_CC_PREFIX='..tool.prefix..' && export RTT_EXEC_PATH='..tool.path..' && '
end

return setEnv
