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
- [x] Run configure, builds, qmllint, install verification, and residue scans.

## FluentUI-Pro Absorption

- [x] Add a lightweight GeoControls-owned state helper for common control surfaces.
- [x] Route buttons, tool buttons, text fields, combo boxes, check boxes, radio buttons,
      switches, and sliders through the shared state helper where practical.
- [x] Expand GuiDemo coverage for default, disabled, hover/pressed/focus, long text, and
      narrow-width states.
- [x] Add dependency-neutral layout and navigation primitives for list tiles, scrollable
      pages, hosted navigation, and closable/movable tab views.
- [x] Keep the absorption dependency-neutral: no FluentUI-Pro URI, CMake, ShaderTools,
      Chart.js, Breakpad, AiAssistant, QRCode/libqrencode, or font-icon import.

## FluentUI-Pro Advanced Candidates

- [x] Add lightweight `DataGrid` and `TreeDataGrid` interaction primitives with explicit
      columns, host-provided array data, sorting signals, selection, expansion, and empty/error states.
- [x] Add a compact `ColorPicker` facade that reuses `CustomColorPicker` and fails visibly
      when no dialog host is provided.
- [x] Add pure-QML date/time picking controls without platform calendar modules or new Qt
      package dependencies.
- [x] Add an explicit route/navigation model primitive that uses host-owned route IDs and
      activation signals instead of router singletons.
- [x] Expand GuiDemo coverage for each advanced candidate, including empty or invalid
      configuration states.

## Acceptance

- `GeoControls::Controls` and `GeoControls::AppShell` are the only exported SDK targets.
- QML users import `GeoControls 1.0` and `GeoControls.AppShell 1.0`.
- No non-build source refers to `legacy product`, `legacy productControls`, `legacy productAppShell`,
  `legacy namespace`, `legacy QML`, `legacy icon path`, or `qrc:/legacy product`.
- AppShell components fail fast or expose explicit empty models/properties instead of relying on
  host global objects.
