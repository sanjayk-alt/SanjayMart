cmake_minimum_required(VERSION 3.20)

project(SanjayMart LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Drogon CONFIG REQUIRED)
find_package(CURL REQUIRED)
find_package(PostgreSQL REQUIRED)

add_executable(SanjayMart main.cc)

target_link_libraries(SanjayMart PRIVATE
    Drogon::Drogon
    CURL::libcurl
    PostgreSQL::PostgreSQL
)
