# libquiche

A cross-platform static library build of Google's QUIC implementation ([QUICHE](https://github.com/google/quiche)), with all dependencies pinned and managed via self-contained vcpkg overlay ports.

---

## Features

- C++20 static library targeting Linux, macOS, and Windows
- All dependencies pinned to known-good commits via overlay ports
- No system-level dependency installation required (except ICU on Linux)
- Protobuf code generation handled automatically at configure time

---

## Dependencies

| Library | Source |
|---|---|
| abseil-cpp | `d407ef1` |
| boringssl | `94c4c7f` |
| protobuf | `a79f2d2` |
| zlib | `f9dd600` |
| ICU (Linux only) | System package |

---

## Prerequisites

### All Platforms
- CMake >= 3.18
- Git
- C++20 capable compiler

### Windows
- Visual Studio 2022 (MSVC v143+)
- Windows SDK

### macOS
- Xcode Command Line Tools
```bash
xcode-select --install
```

### Linux
- GCC 11+ or Clang 13+
- ICU development libraries
```bash
sudo apt install libicu-dev   # Debian/Ubuntu
sudo dnf install libicu-devel # Fedora/RHEL
```

---

## Build

### 1. Clone

```bash
git clone https://github.com/carbon-os/libquiche.git
cd libquiche
```

### 2. Bootstrap vcpkg

```bash
git clone https://github.com/microsoft/vcpkg.git

# Linux/macOS
./vcpkg/bootstrap-vcpkg.sh

# Windows
.\vcpkg\bootstrap-vcpkg.bat
```

### 3. Install Dependencies

```bash
# Linux/macOS
./vcpkg/vcpkg install --overlay-ports=./ports

# Windows
.\vcpkg\vcpkg.exe install --overlay-ports=.\ports
```

### 4. Configure

**Linux / macOS**
```bash
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=./vcpkg/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_OVERLAY_PORTS=./ports
```

**Windows**
```bat
cmake -B build ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=.\vcpkg\scripts\buildsystems\vcpkg.cmake ^
  -DVCPKG_OVERLAY_PORTS=.\ports
```

### 5. Build

```bash
cmake --build build --config Release
```

### Output

```
build/libquiche.a        # Linux/macOS
build\Release\quiche.lib # Windows
```

---

## Linking Against libquiche

**Via find_package:**
```cmake
find_package(quiche REQUIRED)
target_link_libraries(your_target PRIVATE quiche)
```

**Manually:**
```cmake
target_include_directories(your_target PRIVATE /path/to/libquiche)
target_link_libraries(your_target PRIVATE /path/to/libquiche/build/libquiche.a)
```

---

## Directory Structure

```
libquiche/
├── CMakeLists.txt
├── sources.cmake
├── vcpkg.json
├── vcpkg/                  # self-contained vcpkg — do not move
├── ports/                  # pinned overlay ports for all deps
│   ├── abseil-cpp/
│   ├── boringssl/
│   ├── googleurl/
│   ├── protobuf/
│   └── zlib/
├── platform/
│   ├── icufix/
│   ├── quiche/
│   └── quiche_platform_impl/
└── third_party/
    └── quiche/
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `vcpkg: command not found` | Run `bootstrap-vcpkg.sh` first from the repo root |
| `Could not find absl` | Confirm `--overlay-ports=./ports` is passed and `vcpkg install` completed cleanly |
| `ICU not found` on Linux | Run `sudo apt install libicu-dev` |
| Protoc missing at codegen step | Ensure the protobuf port built successfully — check `./vcpkg/buildtrees/protobuf` for errors |
| MSVC iterator debug mismatch | All deps must build with `/D_ITERATOR_DEBUG_LEVEL=0` — wipe `./vcpkg/buildtrees` and reinstall |
| macOS arch mismatch (M1/Intel) | Do not set `CMAKE_OSX_ARCHITECTURES` manually — the protobuf port detects this via `uname -m` |

---

## License

This build wrapper is provided as-is. Refer to each upstream project for its respective license:
- [QUICHE](https://github.com/google/quiche) — BSD 3-Clause
- [abseil-cpp](https://github.com/abseil/abseil-cpp) — Apache 2.0
- [BoringSSL](https://github.com/google/boringssl) — OpenSSL / ISC
- [protobuf](https://github.com/protocolbuffers/protobuf) — BSD 3-Clause
- [zlib](https://github.com/madler/zlib) — zlib License