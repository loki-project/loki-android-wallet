cmake_minimum_required(VERSION 3.10)

message(STATUS "Building for ${ANDROID_ABI}")

add_library(monerujo
    SHARED
    src/main/cpp/monerujo.cpp)

set(LOKI_CORE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/../loki-core-deps" CACHE STRING "Path where loki core android deps have been extracted")

if(NOT EXISTS ${LOKI_CORE_DEPS}/${ANDROID_ABI}/libwallet_api.a OR NOT EXISTS ${LOKI_CORE_DEPS}/wallet2_api.h)
    message(FATAL_ERROR "${LOKI_CORE_DEPS} does not appear to contain extract core deps (couldn't find ${ANDROID_ABI}/libwallet_api.a and/or wallet2_api.h inside it)")
endif()

add_library(wallet_api STATIC IMPORTED)
set_target_properties(wallet_api PROPERTIES IMPORTED_LOCATION
    ${LOKI_CORE_DEPS}/${ANDROID_ABI}/libwallet_api.a)

target_link_libraries(monerujo PRIVATE wallet_api log)
target_include_directories(monerujo PRIVATE ${LOKI_CORE_DEPS})
