cmake_minimum_required(VERSION 3.12)
project(ApexRestDoc VERSION 1.0)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MTd")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

add_executable(ApexRestDoc main.cpp RestEndpoint.cpp FileUtils.cpp ClsFile.cpp TextUtils.cpp CommandLineParser.cpp)
