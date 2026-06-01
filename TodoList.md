# GeoControls Repository Convergence

## Scope

- Rename public CMake and QML surfaces from legacy product names to GeoControls names.
- Keep two reusable libraries: a controls library and a general app shell library.
- Move public icon resource paths under `qrc:/GeoControls/icons/...` while keeping all icon files.
- Remove old `legacy QML`, `legacy namespace`, legacy product target, and legacy product import compatibility.
- Convert AppShell components from implicit host globals to explicit properties and signals.
- Replace application-specific theme tokens and splash/about content with generic GeoControls scope.

## Steps

- [x] Update CMake targets, QML URIs, package exports, and README examples.
- [x] Rewrite QML imports, QRC aliases, and C++ resource URLs.
- [x] Rename C++ namespaces and include guards to GeoControls-owned names.
- [x] Generalize AppShell host contracts.
- [x] Convert Theme tokens to generic surfaces and fonts.
- [x] Update GuiDemo to exercise the new controls and app shell APIs.
- [ ] Run configure, builds, qmllint, install verification, and residue scans.

## Acceptance

- `GeoControls::Controls` and `GeoControls::AppShell` are the only exported SDK targets.
- QML users import `GeoControls 1.0` and `GeoControls.AppShell 1.0`.
- No non-build source refers to `legacy product`, `legacy productControls`, `legacy productAppShell`,
  `legacy namespace`, `legacy QML`, `legacy icon path`, or `qrc:/legacy product`.
- AppShell components fail fast or expose explicit empty models/properties instead of relying on
  host global objects.
