# v0.1.0
# 
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO carbon-os/libquiche
  REF "v${VERSION}"
  SHA512 0
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build()
vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")