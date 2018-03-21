cmake_minimum_required(VERSION 3.0.0)

project(tmp)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
include(SetupPch)

add_executable(main main.cpp)
