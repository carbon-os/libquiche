vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO abseil/abseil-cpp
  REF d407ef122a08203648451e0fec77b3f868b71112
  SHA512 a9ab3b28f894ad814f8313c0bf21398cec90a363196cb13ece808f4383069796e0156adec1a135257bf874e79890309cdb92c538cb9011c6627a865bbd80ca09
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DABSL_PROPAGATE_CXX_STD=ON
    -DABSL_MSVC_STATIC_RUNTIME=ON
    -DABSL_BUILD_TESTING=OFF
    -DCMAKE_CXX_STANDARD=20
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME absl CONFIG_PATH lib/cmake/absl)

file(GLOB TESTING_PC_FILES
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/absl_*test*.pc"
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/absl_*testing*.pc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/absl_*test*.pc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/absl_*testing*.pc"
)
file(REMOVE ${TESTING_PC_FILES})

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/abseil-cpp" RENAME copyright)