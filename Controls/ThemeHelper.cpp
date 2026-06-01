#include "ThemeHelper.h"

#include <QtGui/QFontDatabase>

namespace
{
static QFont makeAppFont()
{
    QFont font = QFontDatabase::systemFont(QFontDatabase::GeneralFont);
    font.setPixelSize(12);
    return font;
}

static QFont makeMonoFont()
{
    QFont font = QFontDatabase::systemFont(QFontDatabase::FixedFont);
    font.setPixelSize(12);
    font.setStyleHint(QFont::Monospace);
    font.setFixedPitch(true);
    return font;
}
} // anonymous namespace

namespace geocontrols
{
ThemeHelper::ThemeHelper(QObject *parent) : QObject(parent)
{
    window_color_ = QColor(246, 247, 249);
    window_text_color_ = QColor(32, 33, 36);
    base_color_ = QColor(255, 255, 255);
    alternate_base_color_ = QColor(238, 241, 245);
    light_color_ = QColor(255, 255, 255);
    midlight_color_ = QColor(216, 221, 229);
    mid_color_ = QColor(182, 190, 200);
    dark_color_ = QColor(185, 192, 201);
    shadow_color_ = QColor(0, 0, 0, 102);
    placeholder_text_color_ = QColor(123, 132, 144);
    accent_color_ = QColor(47, 128, 237);
    link_color_ = QColor(37, 99, 235);
    highlight_color_ = QColor(37, 99, 235);
    highlighted_text_color_ = QColor(255, 255, 255);
    text_color_ = QColor(32, 33, 36);
    disabled_text_color_ = QColor(143, 152, 163);
    button_color_ = QColor(237, 240, 244);
    button_text_color_ = QColor(32, 33, 36);
    button_pressed_color_ = QColor(203, 213, 225);
    button_hovered_color_ = QColor(219, 228, 240);
    button_disabled_color_ = QColor(226, 230, 236);
    divider_color_ = QColor(200, 208, 218);
    rail_surface_color_ = QColor(241, 244, 248);
    input_surface_color_ = QColor(255, 255, 255);
    page_surface_color_ = QColor(246, 247, 249);
    content_surface_color_ = QColor(255, 255, 255);
    popup_surface_color_ = base_color_;
    action_button_color_ = QColor(247, 249, 252);
    action_button_hovered_color_ = QColor(232, 238, 247);
    action_button_pressed_color_ = QColor(218, 227, 241);
    action_button_border_color_ = QColor(200, 208, 218);

    app_font_ = makeAppFont();
    mono_font_ = makeMonoFont();
}

ThemeHelper::~ThemeHelper() = default;

int ThemeHelper::appearance() const noexcept
{
    return 0;
}

QColor ThemeHelper::windowColor() const
{
    return window_color_;
}

QColor ThemeHelper::windowTextColor() const
{
    return window_text_color_;
}

QColor ThemeHelper::baseColor() const
{
    return base_color_;
}

QColor ThemeHelper::alternateBaseColor() const
{
    return alternate_base_color_;
}

QColor ThemeHelper::lightColor() const
{
    return light_color_;
}

QColor ThemeHelper::midlightColor() const
{
    return midlight_color_;
}

QColor ThemeHelper::midColor() const
{
    return mid_color_;
}

QColor ThemeHelper::darkColor() const
{
    return dark_color_;
}

QColor ThemeHelper::shadowColor() const
{
    return shadow_color_;
}

QColor ThemeHelper::placeholderTextColor() const
{
    return placeholder_text_color_;
}

QColor ThemeHelper::accentColor() const
{
    return accent_color_;
}

QColor ThemeHelper::linkColor() const
{
    return link_color_;
}

QColor ThemeHelper::highlightColor() const
{
    return highlight_color_;
}

QColor ThemeHelper::highlightedTextColor() const
{
    return highlighted_text_color_;
}

QColor ThemeHelper::textColor() const
{
    return text_color_;
}

QColor ThemeHelper::disabledTextColor() const
{
    return disabled_text_color_;
}

QColor ThemeHelper::buttonColor() const
{
    return button_color_;
}

QColor ThemeHelper::buttonTextColor() const
{
    return button_text_color_;
}

QColor ThemeHelper::buttonPressedColor() const
{
    return button_pressed_color_;
}

QColor ThemeHelper::buttonHoveredColor() const
{
    return button_hovered_color_;
}

QColor ThemeHelper::buttonDisabledColor() const
{
    return button_disabled_color_;
}

QColor ThemeHelper::dividerColor() const
{
    return divider_color_;
}

QColor ThemeHelper::railSurfaceColor() const
{
    return rail_surface_color_;
}

QColor ThemeHelper::inputSurfaceColor() const
{
    return input_surface_color_;
}

QColor ThemeHelper::pageSurfaceColor() const
{
    return page_surface_color_;
}

QColor ThemeHelper::contentSurfaceColor() const
{
    return content_surface_color_;
}

QColor ThemeHelper::popupSurfaceColor() const
{
    return popup_surface_color_;
}

QColor ThemeHelper::actionButtonColor() const
{
    return action_button_color_;
}

QColor ThemeHelper::actionButtonHoveredColor() const
{
    return action_button_hovered_color_;
}

QColor ThemeHelper::actionButtonPressedColor() const
{
    return action_button_pressed_color_;
}

QColor ThemeHelper::actionButtonBorderColor() const
{
    return action_button_border_color_;
}

QFont ThemeHelper::appFont() const
{
    return app_font_;
}

QFont ThemeHelper::monoFont() const
{
    return mono_font_;
}
} // namespace geocontrols
