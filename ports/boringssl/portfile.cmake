# NOTE: submodule is at third_party/boringssl/src — the /src IS the repo root
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/boringssl
  REF 94c4c7f9e0eeeff72ea1ac6abf1aed5bd2a82c0c
  SHA512 358917bf1d8344c59fa984a67630f51b747a94a6843954b2ccfae780ca18dd9e6bf5d6c4e46c94e2def2e0fcf6585b3b0e457d805262400c3d27f5234f076b95
  HEAD_REF master
)

# from: IF(WIN32) add_compile_definitions(WIN32_LEAN_AND_MEAN NOGDI) ENDIF()
if(VCPKG_TARGET_IS_WINDOWS)
  set(WIN32_OPTIONS
    -DCMAKE_C_FLAGS="/DWIN32_LEAN_AND_MEAN /DNOGDI"
    -DCMAKE_CXX_FLAGS="/DWIN32_LEAN_AND_MEAN /DNOGDI"
  )
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    ${WIN32_OPTIONS}
)

vcpkg_cmake_install()

# BoringSSL has no install() rules — stage manually
file(INSTALL "${SOURCE_PATH}/include/"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Stage libs from build tree (both debug and release)
foreach(CONF rel dbg)
  if(CONF STREQUAL "rel")
    set(DEST "${CURRENT_PACKAGES_DIR}/lib")
  else()
    set(DEST "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()

  foreach(LIB ssl crypto)
    file(GLOB LIB_FILES
      "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${CONF}/**/${LIB}${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    if(LIB_FILES)
      file(INSTALL ${LIB_FILES} DESTINATION "${DEST}")
    endif()
  endforeach()
endforeach()

# from: target_compile_definitions(crypto PRIVATE strdup=_strdup)  [WIN32 only]
# Applied via a usage file so the consuming CMakeLists doesn't need it
if(VCPKG_TARGET_IS_WINDOWS)
  file(WRITE "${CURRENT_PACKAGES_DIR}/share/boringssl/usage"
    "# WIN32: boringssl requires strdup=_strdup on crypto target\n"
    "target_compile_definitions(crypto PRIVATE strdup=_strdup)\n"
  )
endif()

# Generate a config file so find_package(boringssl) works
file(WRITE "${CURRENT_PACKAGES_DIR}/share/boringssl/boringsslConfig.cmake" "
if(TARGET ssl)
  return()
endif()

add_library(ssl STATIC IMPORTED GLOBAL)
set_target_properties(ssl PROPERTIES
    IMPORTED_LOCATION             \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/libssl.a\"
    IMPORTED_LOCATION_DEBUG       \"\${CMAKE_CURRENT_LIST_DIR}/../../debug/lib/libssl.a\"
    INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
)

add_library(crypto STATIC IMPORTED GLOBAL)
set_target_properties(crypto PROPERTIES
    IMPORTED_LOCATION             \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/libcrypto.a\"
    IMPORTED_LOCATION_DEBUG       \"\${CMAKE_CURRENT_LIST_DIR}/../../debug/lib/libcrypto.a\"
    INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
)
")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/boringssl" RENAME copyright)