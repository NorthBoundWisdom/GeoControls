# AGENTS Guide

Goal: keep GeoControls small, independently buildable, and easy to consume from
any Qt application.

## Delivery Rules

- Every code change must include an implementation summary, the verification
  commands that were actually run, and their results.
- Prefer clean architecture over compatibility shims. Do not keep stale product,
  migration, or application-specific paths in this repository.
- Fail fast when a required tool, QML import, resource, dialog host, or model is
  missing. Do not hide missing setup with silent defaults.
- Do not edit generated translation files manually.
- For broad code changes, write or update a short plan before touching code.
  Remove temporary planning checklists once they are completed and reflected in
  stable documentation.

## Repository Boundaries

- `Controls/` must remain reusable and must not depend on application shell,
  application manager, logging, or geometry modules.
- `AppShell/` must remain reusable. Host integrations must be explicit
  properties, models, or signals.
- `GuiDemo/` may use both public modules and demo-only helpers, but demo helpers
  must not become library API.
- The public QML URIs are `GeoControls 1.0` and `GeoControls.AppShell 1.0`.
- Icons used by controls should use stable `qrc:/GeoControls/icons/...` paths.
- Do not add new third-party runtime dependencies, font icon packs, JavaScript
  bundles, shader tool requirements, crash uploaders, or SDK-directory install
  logic without an explicit architecture review.

## C++ And QML Style

- Use C++20.
- Use 4-space indentation, Allman braces for C++, and a 100-column target.
- Prefer forward declarations in headers and target-scoped CMake include paths.
- Keep `.cpp` files including their matching `.h` first, followed by standard,
  Qt, then local headers.
- Use `Type *ptr` pointer alignment.
- Mark virtual overrides with `override`; mark methods `const` and `noexcept`
  when appropriate.
- QML should be formatted by `qmlformat` with the repository `.qmlformat.ini`.
- Public QML APIs should use GeoControls-owned names and explicit host contracts.

## Git Hooks

Enable hooks in a clone with:

```sh
git config core.hooksPath githooks
```

The pre-commit hook formats staged C++ and QML files and re-stages them. Commits
fail if `clang-format` or `qmlformat` is needed but unavailable.

## Verification

Common local commands:

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

cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target all_qmllint
```

Install verification should use an explicit local prefix:

```sh
cmake -S /Users/henrykang/Documents/GeoControls \
    -B /Users/henrykang/Documents/GeoControls/build/install_verify \
    -DCMAKE_PREFIX_PATH="/Users/henrykang/Qt/6.11.1/macos;/opt/homebrew" \
    -DGEOCONTROLS_BUILD_DEMO=OFF \
    -DGEOCONTROLS_INSTALL_SDK=ON \
    -DCMAKE_INSTALL_PREFIX=/Users/henrykang/Documents/GeoControls/build/install_verify/prefix

cmake --build /Users/henrykang/Documents/GeoControls/build/install_verify \
    --target install
```

Static checks:

```sh
rg 'Geo[T]oy|Custom[Q]ml|geo[t]oys|qrc:/[i]cons|qrc:/Geo[T]oy' /Users/henrykang/Documents/GeoControls
rg "Geo2dCore/Define[.]h|rlog/logger[.]h|App[M]anager" /Users/henrykang/Documents/GeoControls
```
