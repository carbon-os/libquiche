cmake_minimum_required(VERSION 3.18)
cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0003 NEW)

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
add_definitions(-D_ITERATOR_DEBUG_LEVEL=0)

project(quiche)

set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_CXX_STANDARD 20)

find_package(absl      REQUIRED)
find_package(protobuf  REQUIRED)
find_package(boringssl REQUIRED)
find_package(ZLIB      REQUIRED)

IF(NOT (WIN32 OR APPLE))
    find_package(ICU COMPONENTS uc i18n REQUIRED)
ENDIF()

include(sources.cmake)

add_library(quiche STATIC ${QUICHE_SOURCES})

IF(APPLE OR WIN32)
    target_sources(quiche PRIVATE third_party/googleurl/url/url_idna_ascii_only.cc)
ELSE()
    target_sources(quiche PRIVATE third_party/googleurl/url/url_idna_icu.cc)
ENDIF()

FILE(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche PROTOMODEL_PATH)
FILE(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche PROTOBINDING_PATH)

add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/cached_network_parameters.pb.h
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/crypto_server_config.pb.h
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/source_address_token.pb.h
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/cached_network_parameters.pb.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/crypto_server_config.pb.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/source_address_token.pb.cc
    DEPENDS
        protobuf::protoc
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/cached_network_parameters.proto
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/crypto_server_config.proto
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/source_address_token.proto
    COMMAND protobuf::protoc
        --proto_path=${PROTOMODEL_PATH}
        --cpp_out=${PROTOBINDING_PATH}
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/cached_network_parameters.proto
    COMMAND protobuf::protoc
        --proto_path=${PROTOMODEL_PATH}
        --cpp_out=${PROTOBINDING_PATH}
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/crypto_server_config.proto
    COMMAND protobuf::protoc
        --proto_path=${PROTOMODEL_PATH}
        --cpp_out=${PROTOBINDING_PATH}
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/source_address_token.proto
)

target_sources(quiche PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/cached_network_parameters.pb.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/crypto_server_config.pb.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/source_address_token.pb.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/cached_network_parameters.pb.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/crypto_server_config.pb.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quiche/quiche/quic/core/proto/source_address_token.pb.cc
)

set_property(TARGET quiche PROPERTY CXX_STANDARD 20)

IF(WIN32)
    target_sources(quiche PRIVATE
        third_party/googleurl/base/strings/string_util_win.cc
        third_party/googleurl/base/strings/string_util_win.h)
    target_compile_definitions(crypto  PRIVATE strdup=_strdup)
    target_compile_definitions(quiche  PRIVATE
        _WINSOCK_DEPRECATED_NO_WARNINGS
        NOMINMAX
        WIN32_LEAN_AND_MEAN
        NOGDI)
ELSE()
    IF(NOT APPLE)
        target_link_libraries(quiche PRIVATE -static-libgcc -static-libstdc++)
    ENDIF()
ENDIF()

target_include_directories(quiche
    PUBLIC platform
    PUBLIC third_party/quiche
    PUBLIC third_party/boringssl/src/include
    PUBLIC third_party/abseil-cpp
    PUBLIC third_party/googleurl
    PUBLIC third_party/zlib
    PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/third_party/zlib
    PUBLIC .
    PUBLIC ${Protobuf_INCLUDE_DIRS}
    PUBLIC ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(quiche
    PRIVATE
    absl::core_headers
    absl::log_severity
    absl::flags
    absl::flags_usage
    absl::flags_parse
    absl::absl_check
    absl::absl_log
    absl::log_flags
    absl::log_initialize
    absl::int128
    absl::strings
    absl::str_format
    absl::flat_hash_map
    absl::any
    absl::synchronization
    absl::time
    absl::status
    absl::statusor
    absl::cleanup
    protobuf::libprotobuf
    ssl
    crypto
    ZLIB::ZLIB
)