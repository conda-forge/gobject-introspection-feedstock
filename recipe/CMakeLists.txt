cmake_minimum_required(VERSION 3.20)
project(conda_gi_installed_test C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GOBJECT REQUIRED IMPORTED_TARGET gobject-2.0)
pkg_check_modules(GIREPOSITORY REQUIRED IMPORTED_TARGET gobject-introspection-1.0)

add_library(condagismoke SHARED condagismoke.c condagismoke.h)
target_compile_definitions(condagismoke PRIVATE CONDA_GI_SMOKE_BUILD)
target_link_libraries(condagismoke PRIVATE PkgConfig::GOBJECT)
if(WIN32)
  set_target_properties(condagismoke PROPERTIES PREFIX "")
endif()

add_executable(gi-repository-consumer consumer.c)
target_link_libraries(gi-repository-consumer PRIVATE condagismoke PkgConfig::GIREPOSITORY)
