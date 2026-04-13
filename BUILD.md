# Building libquiche

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
```bash
sudo apt install libicu-dev   # Debian/Ubuntu
sudo dnf install libicu-devel # Fedora/RHEL
```

---

## Clone the Repo

```bash
git clone https://github.com/carbon-os/libquiche.git
cd libquiche
```

---

## Bootstrap vcpkg

Clone vcpkg into the repo root, then bootstrap it:

```bash
git clone https://github.com/microsoft/vcpkg.git

# Linux/macOS
./vcpkg/bootstrap-vcpkg.sh

# Windows
.\vcpkg\bootstrap-vcpkg.bat
```

---

## Install Dependencies

From the repo root — the overlay ports are already in `./ports`:

```bash
# Linux/macOS
./vcpkg/vcpkg install --overlay-ports=./ports

# Windows
.\vcpkg\vcpkg.exe install --overlay-ports=.\ports
```

---

## Configure

### Linux
```bash
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=./vcpkg/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_OVERLAY_PORTS=./ports
```

### macOS
```bash
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=./vcpkg/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_OVERLAY_PORTS=./ports
```

### Windows
```bat
cmake -B build ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=.\vcpkg\scripts\buildsystems\vcpkg.cmake ^
  -DVCPKG_OVERLAY_PORTS=./ports
```

---

## Build

```bash
cmake --build build --config Release
```

---

## Output

```
# Linux/macOS
build/libquiche.a

# Windows
build\Release\quiche.lib
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

## Linking Against libquiche in Your Project

```cmake
find_package(quiche REQUIRED)
target_link_libraries(your_target PRIVATE quiche)
```

Or manually:

```cmake
target_include_directories(your_target PRIVATE /path/to/libquiche)
target_link_libraries(your_target PRIVATE /path/to/libquiche/build/libquiche.a)
```


# using the lib via vcpkg-configuration

```
vcpkg-configuration.json
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
      "baseline": "0f9da6d26681a7c2ad902197817bc7ece71dab2f",
      "packages": ["quiche", "abseil-cpp", "boringssl", "protobuf", "zlib"]
    }
  ]
}
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