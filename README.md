# libquiche

A cross-platform static library build of Google's QUIC implementation ([QUICHE](https://github.com/google/quiche)), distributed as a vcpkg registry package with all dependencies pinned and versioned.

---

## Features

- C++20 static library targeting Linux, macOS, and Windows
- Installable via vcpkg registry — no manual port cloning required
- All dependencies pinned to known-good commits
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

## Usage

### 1. Bootstrap vcpkg

In your project root, clone vcpkg if you haven't already:

```bash
git clone https://github.com/microsoft/vcpkg.git

# Linux/macOS
./vcpkg/bootstrap-vcpkg.sh

# Windows
.\vcpkg\bootstrap-vcpkg.bat
```

### 2. Configure the Registry

Add a `vcpkg-configuration.json` to your project root pointing to the libquiche registry:

```json
{
  "default-registry": {
    "kind": "git",
    "repository": "https://github.com/microsoft/vcpkg",
    "baseline": "3508985146f1b1d248c67ead13f8f54be5b4f5da"
  },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/carbon-os/libquiche",
      "baseline": "76531099624c3d047744041e22b69a1a30b68430",
      "packages": ["quiche", "abseil-cpp", "boringssl", "protobuf", "zlib"]
    }
  ]
}
```

### 3. Declare the Dependency

Add a `vcpkg.json` manifest to your project root:

```json
{
  "name": "your-app",
  "version": "1.0.0",
  "dependencies": [
    "quiche"
  ]
}
```

### 4. Install Dependencies

```bash
# Linux/macOS
./vcpkg/vcpkg install

# Windows
.\vcpkg\vcpkg.exe install
```

### 5. Configure Your Project

**Linux / macOS**
```bash
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=./vcpkg/scripts/buildsystems/vcpkg.cmake
```

**Windows**
```bat
cmake -B build ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=.\vcpkg\scripts\buildsystems\vcpkg.cmake
```

### 6. Build

```bash
cmake --build build --config Release
```

---

## Linking Against libquiche

In your `CMakeLists.txt`:

```cmake
find_package(quiche REQUIRED)
target_link_libraries(your_target PRIVATE quiche)
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `vcpkg: command not found` | Run `bootstrap-vcpkg.sh` first from your project root |
| `Could not find absl` | Confirm `vcpkg install` completed cleanly and the registry baseline is reachable |
| Registry resolution failure | Ensure `vcpkg-configuration.json` is in the same directory as `vcpkg.json` |
| `ICU not found` on Linux | Run `sudo apt install libicu-dev` |
| Protoc missing at codegen step | Ensure the protobuf package built successfully — check `./vcpkg/buildtrees/protobuf` for errors |
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