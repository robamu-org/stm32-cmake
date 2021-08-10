# Setting this option to ON will cause CMake to add NO_DEFAULT_PATH to the find_program calls
# See https://cmake.org/cmake/help/latest/command/find_program.html for more information about
# this option
option(STM32_TOOLCHAIN_NO_DEFAULT_PATH
	"Do not search CMake default paths to find cross-compiler" 
	OFF
)
get_filename_component(STM32_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
list(APPEND CMAKE_MODULE_PATH ${STM32_CMAKE_DIR})

include(stm32/common)
include(stm32/devices)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

if(STM32_TOOLCHAIN_NO_DEFAULT_PATH)
	find_program(CMAKE_C_COMPILER
		NAMES ${STM32_TARGET_TRIPLET}-gcc PATHS ${TOOLCHAIN_BIN_PATH} 
		NO_DEFAULT_PATH
	)
	find_program(CMAKE_CXX_COMPILER
		NAMES ${STM32_TARGET_TRIPLET}-g++ PATHS ${TOOLCHAIN_BIN_PATH} 
		NO_DEFAULT_PATH
	)
	find_program(CMAKE_ASM_COMPILER
		NAMES ${STM32_TARGET_TRIPLET}-gcc PATHS ${TOOLCHAIN_BIN_PATH} 
		NO_DEFAULT_PATH
	)
else()
	find_program(CMAKE_C_COMPILER NAMES ${STM32_TARGET_TRIPLET}-gcc PATHS ${TOOLCHAIN_BIN_PATH})
	find_program(CMAKE_CXX_COMPILER NAMES ${STM32_TARGET_TRIPLET}-g++ PATHS ${TOOLCHAIN_BIN_PATH})
	find_program(CMAKE_ASM_COMPILER NAMES ${STM32_TARGET_TRIPLET}-gcc PATHS ${TOOLCHAIN_BIN_PATH})
endif()

set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)
