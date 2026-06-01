# GeoControls

GeoControls is a standalone Qt/QML component package. It ships a reusable controls
module, a general app shell module, a full icon resource set, and a demo app.

## Contents

- `Controls/`: reusable QML controls, dialog pages, chart controls, theme helpers,
  `Qml*Dialog` helpers, `QmlMessageBox`, `Vector3SpinBoxWrapper`, and the default
  `ThemeHelper`.
- `AppShell/`: reusable shell components such as toolbars, status bars, command
  input, mini viewer, splash/about screen, and window chrome helpers.
- `GuiDemo/`: a GeoControls example application.
- `icons/`: the full `qrc:/GeoControls/icons/...` asset set.
- `cmake/`: package export files for downstream `find_package(GeoControls)`.

## Requirements

- CMake 3.24 or newer
- Qt 6.8 or newer with `Core`, `Gui`, `Qml`, `Quick`, `QuickControls2`, and `Svg`
- A C++20 compiler

The currently validated local Qt path is `/Users/henrykang/Qt/6.11.1/macos`.

## Build

```sh
cmake -S /Users/henrykang/Documents/GeoControls \
    -B /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    -DCMAKE_PREFIX_PATH="/Users/henrykang/Qt/6.11.1/macos;/opt/homebrew" \
    -DGEOCONTROLS_BUILD_DEMO=ON

cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GeoControlsControls

cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GeoControlsAppShell

cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GuiDemo
```

## Downstream Usage

```cmake
find_package(GeoControls CONFIG REQUIRED)
target_link_libraries(MyApp PRIVATE GeoControls::Controls GeoControls::AppShell)
```

```qml
import GeoControls 1.0
import GeoControls.AppShell 1.0
```

Packaged icon variables:

- `GeoControls_ICON_DIR`
- `GeoControls_APP_ICON_ICO`
- `GeoControls_APP_ICON_ICNS`
- `GeoControls_APP_ICON_PNG`
- `GeoControls_DOCUMENT_ICON_ICO`
- `GeoControls_DOCUMENT_ICON_ICNS`
- `GeoControls_DOCUMENT_ICON_PNG`

## Development Hooks

```sh
git config core.hooksPath githooks
```

The pre-commit hook formats staged C++ files with `clang-format` and staged QML
files with `qmlformat`, then re-stages the formatted files.
