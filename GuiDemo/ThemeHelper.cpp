#include "ThemeHelper.h"

#include <QtCore/QObject>
#include <QtGui/QFontDatabase>

namespace
{
static QFont makeDemoFont()
{
    QFont font = QFontDatabase::systemFont(QFontDatabase::GeneralFont);
    font.setPixelSize(12);
    return font;
}

static QFont makeDemoCmdlineFont()
{
    QFont font = QFontDatabase::systemFont(QFontDatabase::FixedFont);
    font.setPixelSize(12);
    font.setStyleHint(QFont::Monospace);
    font.setFixedPitch(true);
    return font;
}
} // anonymous namespace

namespace networkutil
{
ThemeHelper::ThemeHelper(QObject *parent)
    : QObject(parent)
{
    // Initialize default colors
    window_color_ = QColor(240, 240, 240);
    window_text_color_ = QColor(0, 0, 0);
    base_color_ = QColor(255, 255, 255);
    alternate_base_color_ = QColor(245, 245, 245);
    text_color_ = QColor(0, 0, 0);
    button_color_ = QColor(240, 240, 240);
    button_text_color_ = QColor(0, 0, 0);
    light_color_ = QColor(255, 255, 255);
    midlight_color_ = QColor(227, 227, 227);
    dark_color_ = QColor(120, 120, 120);
    mid_color_ = QColor(160, 160, 160);
    shadow_color_ = QColor(105, 105, 105);
    highlight_color_ = QColor(42, 130, 218);
    highlighted_text_color_ = QColor(255, 255, 255);
    link_color_ = QColor(0, 0, 255);
    placeholder_text_color_ = QColor(128, 128, 128);
    accent_color_ = QColor(0, 120, 215);
    disabled_text_color_ = QColor(128, 128, 128);
    button_pressed_color_ = QColor(200, 200, 200);
    button_hovered_color_ = QColor(220, 220, 220);
    button_disabled_color_ = QColor(240, 240, 240);

    // Initialize default fonts
    app_font_ = makeDemoFont();
    cmdline_font_ = makeDemoCmdlineFont();
}

ThemeHelper::~ThemeHelper() = default;

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
QColor ThemeHelper::textColor() const
{
    return text_color_;
}
QColor ThemeHelper::buttonColor() const
{
    return button_color_;
}
QColor ThemeHelper::buttonTextColor() const
{
    return button_text_color_;
}
QColor ThemeHelper::lightColor() const
{
    return light_color_;
}
QColor ThemeHelper::midlightColor() const
{
    return midlight_color_;
}
QColor ThemeHelper::darkColor() const
{
    return dark_color_;
}
QColor ThemeHelper::midColor() const
{
    return mid_color_;
}
QColor ThemeHelper::shadowColor() const
{
    return shadow_color_;
}
QColor ThemeHelper::highlightColor() const
{
    return highlight_color_;
}
QColor ThemeHelper::highlightedTextColor() const
{
    return highlighted_text_color_;
}
QColor ThemeHelper::linkColor() const
{
    return link_color_;
}
QColor ThemeHelper::placeholderTextColor() const
{
    return placeholder_text_color_;
}
QColor ThemeHelper::accentColor() const
{
    return accent_color_;
}
QColor ThemeHelper::disabledTextColor() const
{
    return disabled_text_color_;
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

QFont ThemeHelper::appFont() const
{
    return app_font_;
}
QFont ThemeHelper::cmdlineFont() const
{
    return cmdline_font_;
}
} // namespace networkutil
