set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO madler/zlib
  REF f9dd6009be3ed32415edf1e89d1bc38380ecb95d
  SHA512 fa00a546b5fc4f0621cb9f452e2329fb4a21f59a93c3eaf1b3f45b364db5f47febaaaeb73dfc04b03bd99f1f3d3775bed4a44d891d95710d56e7ffe3c521df09
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Ensure zlibstatic target name is preserved — your cmake uses zlibstatic not zlib
file(INSTALL "${SOURCE_PATH}/README"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/zlib" RENAME copyright)