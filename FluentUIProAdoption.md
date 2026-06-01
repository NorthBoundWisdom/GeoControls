# FluentUI-Pro 吸收 TodoList

目标：从 `Downloads/FluentUI-Pro` 吸收成熟的控件体验、状态设计和交互模式，
但不把 FluentUI-Pro 作为依赖、子模块或兼容层引入。所有可取部分都应按
GeoControls 现有架构重写进入 `Controls/` 或 `AppShell/`。

## 总体约束

- [x] 保持 GeoControls 小型、独立、可被任意 Qt 应用消费。
- [x] 公共 QML URI 只保留 `GeoControls 1.0` 和 `GeoControls.AppShell 1.0`。
- [x] 不扩大当前 Qt 模块依赖，不新增第三方运行时依赖。
- [x] 控件资源只使用稳定的 `qrc:/GeoControls/icons/...` 路径。
- [x] 默认重写优先：只吸收设计意图、状态行为和 API 形态。
- [x] 每轮只迁入一组相关能力，避免一次性重排控件体系。
- [x] `Controls/` 不依赖应用 shell、日志、应用管理器或 demo helper。
- [x] `AppShell/` 只通过属性、模型、信号与宿主应用集成。
- [x] 缺少必需 import、资源、dialog host 或模型时暴露明确错误，不静默降级。
- [x] 新增公共类型使用 GeoControls 命名和现有样式，不保留 FluentUI-Pro 名称空间。
- [x] 图标优先复用 `icons/` 中已有资产；新增图标必须进入
      `qrc:/GeoControls/icons/...`。
- [x] QML 使用仓库 `.qmlformat.ini`，C++ 使用 C++20 和 AGENTS 约定。

## 永久排除项

以下内容只能作为参考，不能迁入 GeoControls。许可已经由项目所有者确认，但本仓库仍按
“少依赖、少资产、少耦合”的原则执行，不把第三方库和资产作为默认迁入对象。

- [x] 不引入 FluentUI-Pro 的 CMake 结构、安装逻辑、插件输出目录和 Qt SDK 目录写入逻辑。
- [x] 不引入 FluentUI-Pro 的公共或内部 QML URI，包括 `FluentUI`、
      `FluentUI.Controls`、`FluentUI.impl`。
- [x] 不引入 AI assistant、网络模型配置、请求调试日志、模型管理和相关 UI。
- [x] 不引入 Breakpad、崩溃上传、事件追踪和 Gallery 应用逻辑。
- [x] 不引入 `Qt6::ShaderTools`、shader-based effects、热加载、设计器专用集成。
- [x] 不引入 Chart.js、Moment、QRCode/libqrencode、Fluent icon font 或其他外部字体图标。
- [x] 不引入要求下游应用修改 Qt 安装目录、全局 import path 或应用级环境变量的做法。

## Phase 1: 主题与基础状态

- [x] 统一主题 token：背景、前景、分隔线、禁用态、强调色、警告/错误/成功/信息色。
- [x] 补齐控件状态：hover、pressed、checked、focused、disabled、read-only 的视觉规则。
- [x] 统一基础尺寸：圆角、边框宽度、内边距、最小高度、图标间距和文本基线。
- [x] 改进按钮和工具按钮状态表现。
- [x] 改进输入框和组合框状态表现。
- [x] 改进复选框、单选框、开关和滑块状态表现。
- [x] 将可复用状态逻辑沉淀为轻量 QML helper，不引入 FluentUI-Pro 的实现层。
- [x] 在 GuiDemo 中补充默认态、禁用态、hover/pressed/focus 态、长文本和窄宽度演示。

## Phase 2: 常用控件体验补齐

- [x] 重写轻量通知与提示能力：`InfoBar`、`Badge`、结果/状态提示。
- [x] 补齐选择与标签类控件：`Chip`、`SegmentedControl`、`SegmentedButton`。
- [x] 补齐可折叠和路径导航能力：`Expander`、`Breadcrumb`。
- [x] 补齐列表分页和评分交互：`Pagination`、`RatingControl`。
- [x] 所有新增控件都能单独在 GuiDemo 中演示。
- [x] 所有新增控件都使用 `GeoControls 1.0` 导入。

## Phase 3: 布局与导航模式

- [x] 借鉴 `NavigationView` 的信息架构，按 GeoControls AppShell 的显式宿主契约重写。
- [x] 借鉴 `TabView` 的关闭、拖拽、溢出和选中状态设计，优先增强现有 tab 控件族。
- [x] 借鉴 `ListTile`、`ScrollablePage`、轻量页面容器的排版模式，形成通用页面骨架。
- [x] 导航模型由宿主传入，不依赖应用全局对象、路由单例或 Gallery helper。
- [x] 在 GuiDemo 中补充布局与导航的最小宿主演示。

## Phase 4: 高级能力候选

- [x] 先更新根目录 `TodoList.md`，再开始任何高级能力代码改动。
- [x] 评估并重写 `DataGrid`/`TreeDataGrid` 的交互模式：列宽、排序、选择、展开、空态。
- [x] 评估并重写 `ColorPicker` 的 UX，复用现有 `CustomColorPicker` 能力，不引入 shader。
- [x] 评估日期/时间选择器，优先纯 QML 实现，不引入平台日历或额外 Qt 模块。
- [x] 评估窗口路由概念，只吸收显式 API 设计，不迁入 FluentUI-Pro 的 router 单例。
- [x] 为每个高级能力补充 GuiDemo 演示和失败态验证。

## 每轮吸收前检查

- [x] 明确本轮目标、目标控件、宿主模块和不迁入项。
- [x] 若变更范围较大，先更新根目录 `TodoList.md`。
- [x] 确认本轮不会新增 CMake package、Qt 组件、第三方库、字体或 JS bundle。
- [x] 确认新增 API 属于 `GeoControls 1.0` 或 `GeoControls.AppShell 1.0`。
- [x] 确认新增资源使用 `qrc:/GeoControls/icons/...`。

## 每轮实现后检查

- [x] 记录实现 summary。
- [x] 运行 configure：

```sh
cmake -S /Users/henrykang/Documents/GeoControls \
    -B /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    -DCMAKE_PREFIX_PATH="/Users/henrykang/Qt/6.11.1/macos;/opt/homebrew" \
    -DGEOCONTROLS_BUILD_DEMO=ON
```

- [x] 构建 `GeoControlsControls`：

```sh
cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GeoControlsControls
```

- [x] 构建 `GeoControlsAppShell`：

```sh
cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GeoControlsAppShell
```

- [x] 构建 `GuiDemo`：

```sh
cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target GuiDemo
```

- [x] 运行 QML lint：

```sh
cmake --build /Users/henrykang/Documents/GeoControls/build/mac_clang_release \
    --target all_qmllint
```

- [x] 运行 legacy/resource residue scan：

```sh
rg 'Geo[T]oy|Custom[Q]ml|geo[t]oys|qrc:/[i]cons|qrc:/Geo[T]oy' \
    /Users/henrykang/Documents/GeoControls
```

- [x] 运行 shell/application boundary scan：

```sh
rg "Geo2dCore/Define[.]h|rlog/logger[.]h|App[M]anager" \
    /Users/henrykang/Documents/GeoControls
```

- [x] 在最终交付中记录实际运行的 verification commands 和结果。

## 文档维护检查

- [x] 更新本文件后运行文档级验收：

```sh
rg 'FluentUI[.]Controls|FluentUI[.]impl|Qt6::Shader[T]ools|Chart[.]js|Break[p]ad|Ai[A]ssistant|libqr[e]ncode|Qt S[D]K|QT_SDK_D[I]R' \
    /Users/henrykang/Documents/GeoControls/FluentUIProAdoption.md
```

- [x] 确认匹配结果只出现在“永久排除项”或“文档维护检查”语境中。
