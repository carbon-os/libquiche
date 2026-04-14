# v0.1.0
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO carbon-os/libquiche
  REF "v${VERSION}"
  SHA512 36bc5517f03d4014ebb4c30d71daaeb3deba68d1fcd2f08724e3a676d1f73ac4a52ee9e859adaec4792804d4feca12f31be9d9b382b56f6b499cdd4e3cbd66c0
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