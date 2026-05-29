# GeoControls

GeoControls is the standalone QML/C++ controls package extracted from GeoToy.
The public QML module URI is intentionally kept as `GeoToy.Controls 1.0` so
existing GeoToy QML can consume the package without changing type names.

## Contents

- `Controls/`: reusable QML controls, dialog pages, chart controls, theme helpers,
  `Qml*Dialog` helpers, `QmlMessageBox`, and `Vector3SpinBoxWrapper`.
- `GuiDemo/`: a pure controls example application. It does not depend on
  `GeoToy.AppShell` or `GeoToy 1.0`.
- `icons/`: the minimal `qrc:/icons/...` SVG set used by the controls.
- `cmake/`: CMake package export files for downstream `find_package(GeoControls)`.

## Requirements

- CMake 3.24 or newer
- Qt 6.8 or newer with `Core`, `Gui`, `Qml`, `Quick`, `QuickControls2`, and `Svg`
- A C++20 compiler

The currently validated local Qt path is `/Users/henrykang/Qt/6.11.1/macos`.

## Build

Configure and build the controls plus demo:

```sh
cmake -S /Users/henrykang/Documents/GeoControls \
    -B /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    -DCMAKE_PREFIX_PATH="/Users/henrykang/Qt/6.11.1/macos;/opt/homebrew" \
    -DGEOCONTROLS_BUILD_DEMO=ON

cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GeoToyControls

cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GuiDemo
```

Install an SDK package for downstream projects:

```sh
cmake -S /Users/henrykang/Documents/GeoControls \
    -B /Users/henrykang/Documents/GeoControls/build/install_release \
    -DCMAKE_PREFIX_PATH="/Users/henrykang/Qt/6.11.1/macos;/opt/homebrew" \
    -DCMAKE_INSTALL_PREFIX=/Users/henrykang/Documents/GeoControls/build/install_release/prefix \
    -DGEOCONTROLS_INSTALL_SDK=ON \
    -DGEOCONTROLS_BUILD_DEMO=OFF

cmake --build /Users/henrykang/Documents/GeoControls/build/install_release \
    --target install
```

Downstream CMake usage:

```cmake
find_package(GeoControls CONFIG REQUIRED)
target_link_libraries(MyApp PRIVATE GeoToyControls)
```

QML usage:

```qml
import GeoToy.Controls 1.0
```

## Development Hooks

Enable the repository hooks once per clone:

```sh
git config core.hooksPath githooks
```

The pre-commit hook formats staged C++ files with `clang-format` and staged QML
files with `qmlformat`, then re-stages the formatted files. If either formatter
is required and cannot be found, the commit fails.

