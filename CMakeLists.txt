# Usage:
# 1. Copy the directory to your project.
# 2. Import the toolchain and add the directory `as subdirectory`
# ```cmake
# set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/gd32f30x/gcc-cortex-m4.cmake")
#
# add_subdirectory(gd32f30x)
# target_compile_options(gd32f30x PRIVATE -O2 -g)
# ```
# 3. Import the link options from subdirectory for your executable.
# ```
# target_link_options(your_executable PRIVATE $<TARGET_PROPERTY:gd32f30x,INTERFACE_LINK_OPTOINS>)
# ```
# TODO gd32f30x.h: HXTAL_VALUE, IRC8M_VALUE, ....
# TODO FPU
cmake_minimum_required(VERSION 3.22)

project(
    gd32f30x
    LANGUAGES C ASM
)

set(DEVICE "UNKNOWN" CACHE STRING "Specify GD32F30x device")

if(DEVICE STREQUAL "GD32F303CCT6")
    set(VAR_DEVICE_TYPE "GD32F30X_HD")
    set(VAR_STARTUP "${CMAKE_CURRENT_LIST_DIR}/startup_gd32f303cct6.S")
    set(VAR_LINKER_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/linker_gd32f303cct6.ld")
else()
    message(FATAL_ERROR "Please specify the device by DEVCIE. GD32F303CCT6")
endif()

option(GD32E23X_USE_ADC "" OFF)
option(GD32E23X_USE_BKP "" OFF)
option(GD32E23X_USE_CAN "" OFF)
option(GD32E23X_USE_CRC "" OFF)
option(GD32E23X_USE_CTC "" OFF)
option(GD32E23X_USE_DAC "" OFF)
option(GD32E23X_USE_DBG "" OFF)
option(GD32E23X_USE_DMA "" OFF)
option(GD32E23X_USE_ENET "" OFF)
option(GD32E23X_USE_EXMC "" OFF)
option(GD32E23X_USE_EXTI "" OFF)
option(GD32E23X_USE_FMC "" OFF)
option(GD32E23X_USE_FWDGT "" OFF)
option(GD32E23X_USE_GPIO "" OFF)
option(GD32E23X_USE_I2C "" OFF)
option(GD32E23X_USE_PMU "" OFF)
option(GD32E23X_USE_RTC "" OFF)
option(GD32E23X_USE_SDIO "" OFF)
option(GD32E23X_USE_SPI "" OFF)
option(GD32E23X_USE_TIMER "" OFF)
option(GD32E23X_USE_USART "" OFF)
option(GD32E23X_USE_WWDGT "" OFF)

configure_file(${CMAKE_CURRENT_LIST_DIR}/gd32f30x_libopt.h.in ${CMAKE_BINARY_DIR}/gd32f30x_libopt.h)

add_library(gd32f30x STATIC)
target_link_options(gd32f30x
    INTERFACE
    -Wl,-e Reset_Handler
    -Wl,-T${VAR_LINKER_SCRIPT}
)
target_compile_definitions(gd32f30x
    PUBLIC
    GD32F30x
    ${VAR_DEVICE_TYPE}
)
target_include_directories(gd32f30x
    PUBLIC
    ${CMAKE_BINARY_DIR}
    ${CMAKE_CURRENT_LIST_DIR}
    cmsis
    peripheral/inc
)
aux_source_directory(peripheral/src VAR_SOURCES)
target_sources(gd32f30x
    PRIVATE
    ${VAR_STARTUP}
    system_gd32f30x.c
    ${VAR_SOURCES}
)