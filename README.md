# GeoControls

GeoControls is the standalone QML/C++ UI package extracted from GeoToy.
It now ships a reusable controls module, an AppShell module, a full icon set,
and a pure example app.

## Contents

- `Controls/`: reusable QML controls, dialog pages, chart controls, theme helpers,
  `Qml*Dialog` helpers, `QmlMessageBox`, `Vector3SpinBoxWrapper`, and the
  default `ThemeHelper`.
- `AppShell/`: host-injected app shell components such as the toolbar, status
  bar, command input area, mini viewer, splash screen, and window chrome.
- `GuiDemo/`: a pure GeoControls example application.
- `icons/`: the full `qrc:/icons/...` asset set used by Controls and AppShell.
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
target_link_libraries(MyApp PRIVATE GeoToyControls GeoToyAppShell)
```

QML usage:

```qml
import GeoToy.Controls 1.0
import GeoToy.AppShell 1.0
```

Packaged icon variables:

- `GeoControls_ICON_DIR`
- `GeoControls_APP_ICON_ICO`
- `GeoControls_APP_ICON_ICNS`
- `GeoControls_APP_ICON_PNG`
- `GeoControls_FILE_ICON_ICO`
- `GeoControls_FILE_ICON_ICNS`
- `GeoControls_FILE_ICON_PNG`

## Development Hooks

Enable the repository hooks once per clone:

```sh
git config core.hooksPath githooks
```

The pre-commit hook formats staged C++ files with `clang-format` and staged QML
files with `qmlformat`, then re-stages the formatted files. If either formatter
is required and cannot be found, the commit fails.
