pub fn initial() -> &'static str {
#[cfg(target_os = "linux")]
{
r#"{ "tools":
  {
    "scons":["SConstruct"],
    "xmake":["xmake.lua"],
    "make":["Makefile","makefile"],
    "cmake":["CMakeLists.txt"],
    "cargo":["Cargo.toml"]
  },
  "toolchains":
  {
    "arm": {
      "prefix":"arm-none-eabi-",
      "path":"/opt/rt-thread/tools/gnu_gcc/gcc-arm-none-eabi/bin",
      "bsps":["stm32","qemu-vexpress-a9"]
    }
  },
  "smarttoolchains": {
    "armMusl": {
      "prefix": "arm-linux-musleabi-",
      "path": "/opt/rt-thread/tools/gnu_gcc/arm-linux-musleabi/bin",
      "bsps": [
        "qemu-vexpress-a9"
      ]
    },
    "riscv64Musl": {
      "prefix": "riscv64-unknown-linux-musl-",
      "path": "/opt/rt-thread/tools/gnu_gcc/riscv64-linux-musleabi/bin",
      "bsps": [
        "qemu-virt64-riscv"
      ]
    },
    "aarch64Musl": {
      "prefix": "aarch64-linux-musleabi-",
      "path": "/opt/rt-thread/tools/gnu_gcc/aarch64-linux-musleabi/bin",
      "bsps": [
        "qemu-virt64-aarch64",
        "rockchip"
      ]
    }
  }
}"#
}
#[cfg(target_os = "windows")]
{
r#"{ "tools":
  {
    "scons":["SConstruct"],
    "xmake":["xmake.lua"],
    "make":["Makefile","makefile"],
    "cmake":["CMakeLists.txt"],
    "cargo":["Cargo.toml"]
  },
  "toolchains":
  {
    "rt-gcc-arm-none-eabi": {
      "prefix":"arm-none-eabi-",
      "path":"../../../rt-gcc-arm-none-eabi/current/bin",
      "bsps":["stm32","qemu-vexpress-a9"]
    },
    "rt-aarch64-none-elf": {
      "prefix":"aarch64-none-elf-",
      "path":"../../../rt-aarch64-none-elf/current/bin",
      "bsps":["aarch64","rk3568","raspi3-64","raspi4-64"]
    },
    "rt-xpack-riscv-none-embed": {
      "prefix":"riscv-none-embed-",
      "path":"../../../rt-xpack-riscv-none-embed/current/bin",
      "bsps":["k210","gd32vf103v-eval"]
    }
  },
  "smarttoolchains": {
    "arm-smart-musleabi": {
      "prefix": "arm-linux-musleabi-",
      "path": "../../../arm-smart-musleabi/current/bin",
      "bsps": [
        "qemu-vexpress-a9"
      ]
    },
    "riscv64gc-unknown-smart-musl": {
      "prefix": "riscv64-unknown-linux-musl-",
      "path": "../../../riscv64gc-unknown-smart-musl/current/bin",
      "bsps": [
        "qemu-virt64-riscv"
      ]
    },
    "aarch64-smart-musleabi": {
      "prefix": "aarch64-linux-musleabi-",
      "path": "../../../aarch64-smart-musleabi/current/bin",
      "bsps": [
        "qemu-virt64-aarch64",
        "rockchip"
      ]
    }
  }
}"#
}
}
