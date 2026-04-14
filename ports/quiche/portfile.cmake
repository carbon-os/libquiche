# v0.1.0
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO carbon-os/libquiche
  REF "v${VERSION}"
  SHA512 aff1a612a7dc2535bc9d279991208a7a087779dee09758e58a6a683bfc6ddcf19ae3a7d66df7a55867c995a89864bca1327e89f378f438b64767e02e42df0123
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