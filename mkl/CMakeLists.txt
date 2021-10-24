cmake_minimum_required(VERSION 3.13)
enable_testing()
project(oneMKL_Example LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -march=skylake -ffast-math -funroll-loops")

find_package(MKL CONFIG REQUIRED)
#message(STATUS "${MKL_IMPORTED_TARGETS}") #Provides available list of targets based on input
add_executable(sin_perf_mkl sin_perf_mkl.cpp)

target_compile_options(sin_perf_mkl PUBLIC $<TARGET_PROPERTY:MKL::MKL,INTERFACE_COMPILE_OPTIONS>)
target_include_directories(sin_perf_mkl PUBLIC $<TARGET_PROPERTY:MKL::MKL,INTERFACE_INCLUDE_DIRECTORIES>)
target_link_libraries(sin_perf_mkl PUBLIC $<LINK_ONLY:MKL::MKL>)

add_test(NAME mytest COMMAND sin_perf_mkl)
if(MKL_ENV)
  set_tests_properties(mytest PROPERTIES ENVIRONMENT "${MKL_ENV}")
endif()
