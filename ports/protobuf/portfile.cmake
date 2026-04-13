vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO protocolbuffers/protobuf
  REF a79f2d2e9fadd75e94f3fe40a0399bf0a5d90551
  SHA512 0649a164116479f6d9898bc18039f8825209bd90cbf04f1c203d787d05ffddd7903ff9cfb4cd6f11a39b63e64364e2ea0638ef71323757cab0e430c54dbe1029
  HEAD_REF main
)

# from: if(APPLE) execute_process(uname -m ...) set_target_properties(... OSX_ARCHITECTURES)
if(VCPKG_TARGET_IS_OSX)
  execute_process(
    COMMAND uname -m
    OUTPUT_VARIABLE HOST_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(OSX_ARCH_OPTION "-DCMAKE_OSX_ARCHITECTURES=${HOST_ARCH}")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Dprotobuf_WITH_ZLIB=OFF            # from: SET(protobuf_WITH_ZLIB OFF ...)
    -Dprotobuf_BUILD_TESTS=OFF          # from: SET(protobuf_BUILD_TESTS OFF ...)
    -Dprotobuf_INSTALL=ON
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON # from: set(protobuf_BUILD_PROTOC_BINARIES ON)
    -Dprotobuf_MSVC_STATIC_RUNTIME=ON   # from: set(protobuf_MSVC_STATIC_RUNTIME ON)
    -DCMAKE_CXX_STANDARD=20
    ${OSX_ARCH_OPTION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME protobuf CONFIG_PATH lib/cmake/protobuf)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/protobuf" RENAME copyright)