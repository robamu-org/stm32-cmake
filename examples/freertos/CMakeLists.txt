cmake_minimum_required(VERSION 3.13)
set(PROJ_NAME stm32-freertos)
set(STM32_CMAKE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../..)

# Please note: When using CMSIS, it is recommended to use the FreeRTOS version supplied in the 
# Cube repository because more recent kernels might be incompatible
option(USE_CMSIS_RTOS "Use CMSIS RTOS provided by Cube repository" ON)
option(USE_CMSIS_RTOS_V2 "Use CMSIS RTOS_V2 provided by Cube repository" ON)

# This must come before the project call!
set(CMAKE_TOOLCHAIN_FILE ${STM32_CMAKE_PATH}/cmake/stm32_gcc.cmake)
project(${TARGET_NAME} CXX C ASM)
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

# Can be used to print out all devices for the H7 family
# include(${STM32_CMAKE_PATH}/cmake/stm32/devices.cmake)
# stm32_print_devices_by_family(FAMILY H7)
# stm32_print_devices_by_family(FAMILY F4)

option(FREERTOS_F407VG_EXAMPLE "Compile FreeRTOS example for the F407VG board" ON)
option(FREERTOS_H743ZI_EXAMPLE "Compile FreeRTOS example for the H743ZI board" OFF)

set(HAL_COMP_LIST RCC GPIO CORTEX)
set(CMSIS_COMP_LIST "")
set(FREERTOS_COMP_LIST "")

if(USE_CMSIS_RTOS)
    list(APPEND CMSIS_COMP_LIST RTOS)
endif()
if(USE_CMSIS_RTOS_V2)
    list(APPEND CMSIS_COMP_LIST RTOS_V2)
endif()

if(FREERTOS_H743ZI_EXAMPLE)
    list(APPEND CMSIS_COMP_LIST STM32H743ZI STM32H7_M7)
    list(APPEND HAL_COMP_LIST STM32H7M7 STM32H743ZI)
    list(APPEND FREERTOS_COMP_LIST ARM_CM7)
endif()

if(FREERTOS_F407VG_EXAMPLE)
    list(APPEND CMSIS_COMP_LIST STM32F407VG)
    list(APPEND HAL_COMP_LIST STM32F407VG)
    list(APPEND FREERTOS_COMP_LIST ARM_CM4)
endif()

find_package(CMSIS COMPONENTS ${CMSIS_COMP_LIST} REQUIRED)
find_package(HAL COMPONENTS ${HAL_COMP_LIST} REQUIRED)
find_package(FreeRTOS COMPONENTS ${FREERTOS_COMP_LIST} REQUIRED)

set(PROJECT_SOURCES
    main.cpp
)

# This is required because FreeRTOSConfig.h, stm32hxx_hal_conf.h and main.h
# need to be included
set(INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}
)

if(FREERTOS_H743ZI_EXAMPLE)
    set(${TARGET_NAME} ${PROJ_NAME}-h743zi)
    add_executable(${TARGET_NAME})

    target_sources(${TARGET_NAME} PRIVATE ${PROJECT_SOURCES})
    target_include_directories(${TARGET_NAME} PRIVATE ${INCLUDE_DIRS})
    target_link_libraries(${EXEC_NAME} PRIVATE
        FreeRTOS::Timers
        FreeRTOS::Heap::4
        FreeRTOS::ARM_CM7 
        HAL::STM32::H7::M7::RCC
        HAL::STM32::H7::M7::GPIO
        HAL::STM32::H7::M7::CORTEX
        CMSIS::STM32::H743ZI::M7
        STM32::NoSys
    )
    if(USE_CMSIS_RTOS)
        target_link_libraries(${EXEC_NAME} PRIVATE
            CMSIS::STM32::H7::M7::RTOS
        )
    endif()

    stm32_print_size_of_target(${TARGET_NAME})
    stm32_generate_binary_file(${TARGET_NAME})
    stm32_generate_hex_file(${TARGET_NAME})
endif()

if(FREERTOS_F407VG_EXAMPLE)
    set(${TARGET_NAME} ${PROJ_NAME}-f407vg)
    add_executable(${TARGET_NAME})
    target_sources(${TARGET_NAME} PRIVATE ${PROJECT_SOURCES})
    target_include_directories(${TARGET_NAME} PRIVATE ${INCLUDE_DIRS})
    target_link_libraries(${EXEC_NAME} PRIVATE
        FreeRTOS::Timers
        FreeRTOS::Heap::1
        FreeRTOS::ARM_CM4F 
        HAL::STM32::F4::RCC
        HAL::STM32::F4::GPIO
        HAL::STM32::F4::CORTEX
        CMSIS::STM32::F407VG 
        STM32::NoSys
    )
    if(USE_CMSIS_RTOS)
        target_link_libraries(${EXEC_NAME} PRIVATE
            CMSIS::STM32::F4::RTOS
        )
    endif()

    stm32_print_size_of_target(${TARGET_NAME})
    stm32_generate_binary_file(${TARGET_NAME})
    stm32_generate_hex_file(${TARGET_NAME})
endif()
