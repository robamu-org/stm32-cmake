if((NOT STM32_HAL_${FAMILY}_PATH) AND (NOT STM32_CUBE_${FAMILY}_PATH))
    set(STM32_CUBE_${FAMILY}_PATH $ENV{STM32_CUBE_${FAMILY}_PATH} CACHE PATH "Path to STM32Cube${FAMILY}")
endif()

if((NOT STM32_HAL_${FAMILY}_PATH) AND (NOT STM32_CUBE_${FAMILY}_PATH))
    set(STM32_CUBE_${FAMILY}_PATH /opt/STM32Cube${FAMILY} CACHE PATH "Path to STM32Cube${FAMILY}")
    message(STATUS 
        "Neither STM32_CUBE_${FAMILY}_PATH nor STM32_HAL_${FAMILY}_PATH specified, "
        "using default STM32_CUBE_${FAMILY}_PATH: ${STM32_CUBE_${FAMILY}_PATH}"
    )
endif()

message(STATUS "${STM32_CUBE_${FAMILY}_PATH}/Middlewares/Third_Party/LwIP")

find_path(LwIP_ROOT
    NAMES CMakeLists.txt
    PATHS "${STM32_CUBE_${FAMILY}_PATH}/Middlewares/Third_Party/LwIP"
    NO_DEFAULT_PATH
)

if(LwIP_ROOT MATCHES "LwIP_ROOT-NOTFOUND")
    message(WARNING "LwIP root foolder not found. LwIP might not be supported")
endif()

set(LWIP_DIR ${LwIP_ROOT})

find_path(LwIP_SOURCE_PATH
    NAMES Filelists.cmake
    PATHS "${STM32_CUBE_${FAMILY}_PATH}/Middlewares/Third_Party/LwIP/src"
    NO_DEFAULT_PATH
)

if(LwIP_SOURCE_PATH MATCHES "LwIP_SOURCE_PATH-NOTFOUND")
    message(WARNING "LwIP filelist CMake file not found. Build might fail")
endif()

if(IS_DIRECTORY "${LwIP_SOURCE_PATH}/include")
    set(LwIP_INCLUDE_DIR "${LwIP_SOURCE_PATH}/include")
else()
    message(WARNING "LwIP include directory not found. Build might fail")
endif()

if(IS_DIRECTORY "${LwIP_ROOT}/system")
    set(LwIP_SYS_INCLUDE_DIR "${LwIP_ROOT}/system")
else()
    message(WARNING "LwIP system include directory not found. Build might fail")
endif()

# Use Filelists.cmake to get list of sources to compile
include("${LwIP_SOURCE_PATH}/Filelists.cmake")

if(NOT (TARGET LwIP))
    add_library(LwIP INTERFACE IMPORTED)
    target_sources(LwIP INTERFACE ${lwipcore_SRCS})
    target_include_directories(LwIP INTERFACE ${LwIP_INCLUDE_DIR} ${LwIP_SYS_INCLUDE_DIR})
endif()

if(NOT (TARGET LwIP::IPv4))
    add_library(LwIP::IPv4 INTERFACE IMPORTED)
    target_sources(LwIP::IPv4 INTERFACE ${lwipcore4_SRCS})
    target_link_libraries(LwIP::IPv4 INTERFACE LwIP)
endif()

if(NOT (TARGET LwIP::IPv6))
    add_library(LwIP::IPv6 INTERFACE IMPORTED)
    target_sources(LwIP::IPv6 INTERFACE ${lwipcore6_SRCS})
    target_link_libraries(LwIP::IPv6 INTERFACE LwIP)
endif()

if(NOT (TARGET LwIP::API))
    add_library(LwIP::API INTERFACE IMPORTED)
    target_sources(LwIP::API INTERFACE ${lwipapi_SRCS})
    target_link_libraries(LwIP::API INTERFACE LwIP)
endif()

if(NOT (TARGET LwIP::NETIF))
    add_library(LwIP::NETIF INTERFACE IMPORTED)
    target_sources(LwIP::NETIF INTERFACE ${lwipnetif_SRCS})
    target_link_libraries(LwIP::NETIF INTERFACE LwIP)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LwIP
    REQUIRED_VARS LwIP_ROOT LwIP_INCLUDE_DIR LwIP_SYS_INCLUDE_DIR
    FOUND_VAR LwIP_FOUND
    HANDLE_COMPONENTS
)