if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

cmake_minimum_required(VERSION 3.24)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

project(xtool LANGUAGES Swift)
option(BUILD_SHARED_LIBS "Build shared libraries by default" YES)

set(CMAKE_Swift_LANGUAGE_VERSION 5)
set(CMAKE_Swift_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(CMAKE_POSITION_INDEPENDENT_CODE ${BUILD_SHARED_LIBS})

# set(CMAKE_FIND_DEBUG_MODE TRUE)

if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
  find_package(Foundation QUIET)
endif()

find_package(PackageDescription REQUIRED)

add_library(XToolProductTypes
  Sources/XToolProductTypes/Dump.swift
  Sources/XToolProductTypes/Product.swift
  Sources/XToolProductTypes/ProductSchema.swift
)

target_compile_options(XToolProductTypes PUBLIC
  $<$<COMPILE_LANGUAGE:Swift>:-package-description-version$<SEMICOLON>999.0>)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
  target_link_options(XToolProductTypes PRIVATE
    "SHELL:-Xlinker -install_name -Xlinker @rpath/libXToolProductTypes.dylib")
endif()

set_target_properties(XToolProductTypes PROPERTIES
    Swift_MODULE_NAME XToolProductTypes
    Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/XToolProductTypes
    INSTALL_NAME_DIR \\@rpath
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/XToolProductTypes
    OUTPUT_NAME XToolProductTypes
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/XToolProductTypes
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/XToolProductTypes
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/XToolProductTypes
)

target_link_libraries(XToolProductTypes PRIVATE PackageDescription)

if(NOT CMAKE_SYSTEM_NAME STREQUAL Darwin)
  target_link_libraries(XToolProductTypes PRIVATE Foundation)
  target_link_options(XToolProductTypes PRIVATE "SHELL:-no-toolchain-stdlib-rpath")
  set_target_properties(XToolProductTypes PROPERTIES
    BUILD_WITH_INSTALL_RPATH TRUE
    INSTALL_RPATH "$ORIGIN/../../$<LOWER_CASE:${CMAKE_SYSTEM_NAME}>")
endif()

install(FILES
  ${CMAKE_BINARY_DIR}/XToolProductTypes/XToolProductTypes.swiftmodule
  ${CMAKE_BINARY_DIR}/XToolProductTypes/XToolProductTypes.swiftdoc
  DESTINATION lib/xtool/XToolProductTypes
)

install(TARGETS XToolProductTypes
  DESTINATION lib/xtool/XToolProductTypes)