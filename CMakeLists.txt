cmake_minimum_required(VERSION 3.12)
project(ApexRestDoc VERSION 1.0)
set(CMAKE_CXX_STANDARD 17)

add_executable(ApexRestDoc main.cpp RestEndpoint.cpp)
