set(swift_runtime_resource_cmd "${CMAKE_Swift_COMPILER}" -print-target-info)

if(CMAKE_Swift_COMPILER_TARGET)
  list(APPEND swift_runtime_resource_cmd -target ${CMAKE_Swift_COMPILER_TARGET})
endif()

execute_process(
  COMMAND ${swift_runtime_resource_cmd}
  OUTPUT_VARIABLE target_info_json
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(VERBOSE "-- Swift target info: ${swift_runtime_resource_cmd}\n${target_info_json}")

string(JSON swift_resource_path GET "${target_info_json}" "paths" "runtimeResourcePath")
if(swift_resource_path STREQUAL "")
  message(FATAL_ERROR "Swift's runtime resource path was not found.")
endif()
cmake_path(CONVERT "${swift_resource_path}" TO_CMAKE_PATH_LIST swift_resource_path)
cmake_path(APPEND swift_resource_path "pm" "ManifestAPI" OUTPUT_VARIABLE MANIFEST_API_PATH)

find_library(
  PackageDescription_LIBRARIES PackageDescription
  HINTS "${MANIFEST_API_PATH}"
)
find_file(
  PackageDescription_INCLUDE_DIRS PackageDescription.swiftmodule
  HINTS "${MANIFEST_API_PATH}"
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PackageDescription 
  REQUIRED_VARS PackageDescription_LIBRARIES PackageDescription_INCLUDE_DIRS
)

if(NOT TARGET PackageDescription)
  add_library(PackageDescription UNKNOWN IMPORTED)
  get_filename_component(PackageDescription_INCLUDE_DIRS
    ${PackageDescription_INCLUDE_DIRS} DIRECTORY)
  set_target_properties(PackageDescription PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${PackageDescription_INCLUDE_DIRS}
    IMPORTED_LOCATION ${PackageDescription_LIBRARIES})
endif()