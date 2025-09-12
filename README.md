## GD32E23x

[GD32E23x](https://www.gigadevice.com.cn/product/mcu/main-stream-mcus/gd32f30x-series) 是 GigaDevice 的一款 Cortex-M4 MCU，本仓库是对官方标准库的重新整理，包含以下内容：

+ `cmsis/`：CMSIS 内核头文件 (`V3.30`)
+ `peripheral/`：GD32F30x 外设标准库
+ `gcc-cortex-m4.cmake`：`arm-none-eabi-gcc` 工具链定义及 Cortex-M4 编译配置，包括指定 `nosys` 和 `nano` 两个 SPECS，并允许链接 `CRT - startfiles`（支持使用 GCC 构造器属性），以及启动 FPU
+ `gd32f30x.h`：标准库接口头文件
+ `CMakeLists.txt`：标准库 CMake 接口
+ `system_gd32f30x.c`：提供 `SystemCoreClock`、`SystemCoreClockUpdate`，以及 `SystemInit`（复位时钟树，使用内部时钟源作为系统时钟，中断向量表于 FLASH，更新 `SystemCoreClock`）
+ 启动代码：初始化全局数据区、依次调用 `SystemInit`、`__libc_init_array`、`main`；**外设中断函数弱定义，默认为无限循环；内核异常未定义，需要用户提供**
+ 链接脚本：表示区段位置和区段大小的符号请查看源代码（参考 newlib-nano 所需符号所编写）

### 1. 使用方式

1. 下载该仓库至本地

2. 在项目 CMake 配置中，使用 `add_subdirectory(gd32f30x)` 添加标准库，可使用 `target_xxx` 为该标准库的编译增加配置，使用 `target_link_libraries` 使可执行程序链接到标准库

3. 注意通过 `$<TARGET_PROPERTY:gd32f30x,INTERFACE_LINK_OPTOINS>` 提取标准库所使用的链接参数（指定程序入口为 `Reset_Handler`、指定链接脚本），然后应用到可执行程序的链接中

4. 在 CMake 初始化时

   + 通过 `-DDEVICE=GD32F303CCT6` 指定 MCU 具体型号

   + 通过 `-DGD32F30X_USE_XXX` 来指定所需使用的外设，自动生成 `gd32f30x_libopt.h` 至构建目录（部分 `SystemInit` 中所需使用的外设已默认开启）

### 2. 后续路线

- [ ] 系统学习 ARM 汇编，优化启动代码
- [ ] 系统学习 GCC-Linkerscript，优化链接脚本
- [ ] 编写启动代码和链接脚本模板，使 CMake 能根据 MCU 型号生成具体代码
- [ ] 升级 CMSIS 版本（可能不会做）

### 3. 参考用法

```cmake
cmake_minimum_required(VERSION 3.22)
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/gd32f30x/gcc-cortex-m4.cmake")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(VAR_COMPILE_OPTIONS
    -O2
    -g
    -ffunction-sections
    -fdata-sections
)
set(VAR_LINK_OPTIONS
    -Wl,--print-memory-usage
    -Wl,--gc-sections
)

add_subdirectory(gd32f30x)
target_compile_options(gd32f30x
    PRIVATE
    ${VAR_COMPILE_OPTIONS}
)

project(firmware
    LANGUAGES C
)

add_gd32e23x_executable(firmware)
aux_source_directory(src VAR_SOURCES)
target_sources(firmware
    PRIVATE ${VAR_SOURCES}
)
target_include_directories(firmware
    PRIVATE src
)
target_compile_options(firmware
    PRIVATE ${VAR_COMPILE_OPTIONS}
)
target_link_options(firmware
    PRIVATE
    ${VAR_LINK_OPTIONS}
    -Wl,-Map=${CMAKE_BINARY_DIR}/firmware.map
    $<TARGET_PROPERTY:gd32f30x,INTERFACE_LINK_OPTOINS>
)
target_link_libraries(firmware
    PRIVATE gd32f30x
)
add_custom_command(TARGET firmware POST_BUILD
    COMMAND
    arm-none-eabi-objcopy -O binary
    "${PROJECT_BINARY_DIR}/${PARAM_NAME}"
    "${PROJECT_BINARY_DIR}/${PARAM_NAME}.bin"
)
```