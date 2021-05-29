cmake_minimum_required(VERSION 3.10.2)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(manual_control)

add_executable(manual_control
    manual_control.cpp
    joystick.cpp
)

find_package(MAVSDK REQUIRED)
find_package(SDL2 REQUIRED)
find_package(Threads REQUIRED)

target_link_libraries(manual_control
    MAVSDK::mavsdk_action
    MAVSDK::mavsdk_telemetry
    MAVSDK::mavsdk_manual_control
    MAVSDK::mavsdk
    SDL2::SDL2
    Threads::Threads
)

if(NOT MSVC)
    add_compile_options(manual_control PRIVATE -Wall -Wextra)
else()
    add_compile_options(manual_control PRIVATE -WX -W2)
endif()
