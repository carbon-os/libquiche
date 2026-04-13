# v0.1.0
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO carbon-os/libquiche
  REF "v${VERSION}"
  SHA512 954546d235e54b0e2038bcfa6b968273346a1ddabb8155ffbb845edb051e63023da4921a1a210f9d1784747f36be3d90424c7ad29caecee933db9d04c09bae33
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