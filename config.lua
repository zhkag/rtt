config = {}

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

return config