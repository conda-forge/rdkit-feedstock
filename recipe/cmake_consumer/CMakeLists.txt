cmake_minimum_required(VERSION 3.18)
project(rdkit_consumer LANGUAGES CXX)

# Links every exported RDKit target, so one whose link interface names a package
# rdkit-config.cmake does not find fails here. No C++ standard is set: the exported
# targets must carry the one their headers need.
find_package(RDKit REQUIRED)
get_directory_property(rdkit_targets IMPORTED_TARGETS)
list(FILTER rdkit_targets INCLUDE REGEX "^RDKit::")
message(STATUS "RDKit_HAS_PYTHON_WRAPPERS=${RDKit_HAS_PYTHON_WRAPPERS}")

add_executable(consumer main.cpp)
target_link_libraries(consumer PRIVATE ${rdkit_targets})

# The Boost.Python targets need libpython, so they are found but not linked.
option(EXPECT_RDKITPYTHON "Require the rdkitpython package as well" OFF)
if(EXPECT_RDKITPYTHON)
  if(NOT RDKit_HAS_PYTHON_WRAPPERS)
    message(FATAL_ERROR "RDKit_HAS_PYTHON_WRAPPERS is OFF beside an installed rdkitpython")
  endif()
  find_package(rdkitpython REQUIRED)
  if(NOT TARGET RDKit::rdkit_py_base)
    message(FATAL_ERROR "rdkitpython did not define RDKit::rdkit_py_base")
  endif()
elseif(RDKit_HAS_PYTHON_WRAPPERS)
  message(FATAL_ERROR "RDKit_HAS_PYTHON_WRAPPERS is ON without rdkitpython installed")
endif()
