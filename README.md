# GeoControls

GeoControls is a small, reusable Qt/QML component package. It provides two public
QML modules, a CMake package export, a stable icon resource namespace, and a demo
application that exercises the reusable controls.

## Modules

- `GeoControls 1.0`: reusable controls, dialogs, chart primitives, theme tokens,
  input helpers, data/navigation controls, and icon-backed widgets.
- `GeoControls.AppShell 1.0`: reusable application shell pieces such as command
  input, status/tool bars, route views, splash/about UI, mini viewer, and window
  chrome helpers.

Repository layout:

- `Controls/`: QML controls plus the small C++ helpers used by those controls.
- `AppShell/`: shell components with explicit host-provided properties, models,
  and signals.
- `GuiDemo/`: demo application for local inspection and regression checks.
- `icons/`: assets exposed through `qrc:/GeoControls/icons/...`.
- `cmake/`: package config template for downstream `find_package`.

## Requirements

- CMake 3.24 or newer
- Qt 6.8 or newer with `Core`, `Gui`, `Qml`, `Quick`, `QuickControls2`, and `Svg`
- A C++20 compiler

## Build

Configure the repository with your Qt prefix:

```sh
cmake -S . \
    -B build/mac_clang_release \
    -DCMAKE_PREFIX_PATH="/path/to/Qt;/opt/homebrew" \
    -DGEOCONTROLS_BUILD_DEMO=ON
```

Build the libraries and demo:

```sh
cmake --build build/mac_clang_release --target GeoControlsControls
cmake --build build/mac_clang_release --target GeoControlsAppShell
cmake --build build/mac_clang_release --target GuiDemo
```

Run QML lint:

```sh
cmake --build build/mac_clang_release --target all_qmllint
```

## Install

GeoControls does not install into the Qt SDK. To produce a package in an explicit
prefix:

```sh
cmake -S . \
    -B build/install_release \
    -DCMAKE_PREFIX_PATH="/path/to/Qt;/opt/homebrew" \
    -DGEOCONTROLS_BUILD_DEMO=OFF \
    -DGEOCONTROLS_INSTALL_SDK=ON \
    -DCMAKE_INSTALL_PREFIX="$PWD/build/install_release/prefix"

cmake --build build/install_release --target install
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

Controls should reference icons with stable resource URLs:

```qml
source: "qrc:/GeoControls/icons/Close.svg"
```

## Development

Enable repository hooks in each clone:

```sh
git config core.hooksPath githooks
```

The pre-commit hook formats staged C++ files with `clang-format` and staged QML
files with `qmlformat`, then re-stages the formatted files.

Before sending a change, run the relevant build targets and these residue checks:

```sh
rg 'Geo[T]oy|Custom[Q]ml|geo[t]oys|qrc:/[i]cons|qrc:/Geo[T]oy' .
rg "Geo2dCore/Define[.]h|rlog/logger[.]h|App[M]anager" .
```
