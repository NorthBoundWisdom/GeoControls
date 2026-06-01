# AGENTS Guide

Goal: keep GeoControls small, independently buildable, and easy to consume from
any Qt application.

## Delivery Rules

- Every code change must include the implementation summary, the verification
  commands that were actually run, and the result.
- Prefer clean architecture over compatibility shims. Do not keep legacy or
  application-specific paths in this repository.
- Fail fast when a required tool, QML import, resource, or dialog host is missing.
  Do not hide missing setup with silent defaults.
- Do not edit generated translation files manually.
- If a change is broad, add or update a Markdown TodoList before touching code.

## Repository Boundaries

- `Controls/` must remain reusable and must not depend on application shell,
  application manager, logging, or geometry modules.
- `AppShell/` must remain reusable. Host integrations must be explicit properties,
  models, or signals.
- `GuiDemo/` may use both public modules and demo-only helpers, but demo helpers
  must not become library API.
- The public QML URIs are `GeoControls 1.0` and `GeoControls.AppShell 1.0`.
- Icons used by controls should use stable `qrc:/GeoControls/icons/...` paths.

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

## Git Hooks

Enable hooks in a clone with:

```sh
git config core.hooksPath githooks
```

The pre-commit hook formats staged C++ and QML files and re-stages them. Commits
fail if `clang-format` or `qmlformat` is needed but unavailable.

## Verification

Common commands:

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

Static checks:

```sh
rg 'Geo[T]oy|Custom[Q]ml|geo[t]oys|qrc:/[i]cons|qrc:/Geo[T]oy' /Users/henrykang/Documents/GeoControls
rg "Geo2dCore/Define.h|rlog/logger.h|AppManager" /Users/henrykang/Documents/GeoControls
```
