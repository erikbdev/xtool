if(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
  # TODO
else()
  # Check if swiftly is installed
  execute_process(
    COMMAND swiftly use --print-location
    OUTPUT_VARIABLE SWIFTSDK_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(SWIFTSDK_PATH STREQUAL "")
    cmake_path(SET "/usr/lib/swift")
  endif()
  cmake_path(CONVERT "${SWIFTSDK_PATH}" TO_CMAKE_PATH_LIST SWIFTSDK_PATH)
  cmake_path(APPEND SWIFTSDK_PATH "usr" "lib" "swift")
endif()

cmake_path(APPEND SWIFTSDK_PATH "pm" "ManifestAPI")

find_library(
  PackageDescription_LIBRARIES PackageDescription
  HINTS "${SWIFTSDK_PATH}"
)
find_file(
  PackageDescription_INCLUDE_DIRS PackageDescription.swiftmodule
  HINTS "${SWIFTSDK_PATH}"
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