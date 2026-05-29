#ifndef CONTROLS_THEME_HELPER_H
#define CONTROLS_THEME_HELPER_H

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtGui/QFont>
#include <QtQml/qqmlregistration.h>

namespace geocontrols
{
class ThemeHelper : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(DefaultThemeHelper)

    Q_PROPERTY(int appearance READ appearance NOTIFY colorsChanged)

    Q_PROPERTY(QColor windowColor READ windowColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor windowTextColor READ windowTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor baseColor READ baseColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor alternateBaseColor READ alternateBaseColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor lightColor READ lightColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor midlightColor READ midlightColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor midColor READ midColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor darkColor READ darkColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor shadowColor READ shadowColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor placeholderTextColor READ placeholderTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor linkColor READ linkColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor highlightColor READ highlightColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor highlightedTextColor READ highlightedTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor textColor READ textColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor disabledTextColor READ disabledTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor buttonColor READ buttonColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor buttonTextColor READ buttonTextColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor buttonPressedColor READ buttonPressedColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor buttonHoveredColor READ buttonHoveredColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor buttonDisabledColor READ buttonDisabledColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor chromeDividerColor READ chromeDividerColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor navigationSurfaceColor READ navigationSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor commandSurfaceColor READ commandSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor chatPageSurfaceColor READ chatPageSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor chatContentSurfaceColor READ chatContentSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor chatComposerSurfaceColor READ chatComposerSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor chatActionButtonColor READ chatActionButtonColor NOTIFY colorsChanged)
    Q_PROPERTY(
        QColor chatActionButtonHoveredColor READ chatActionButtonHoveredColor NOTIFY colorsChanged)
    Q_PROPERTY(
        QColor chatActionButtonPressedColor READ chatActionButtonPressedColor NOTIFY colorsChanged)
    Q_PROPERTY(
        QColor chatActionButtonBorderColor READ chatActionButtonBorderColor NOTIFY colorsChanged)

    Q_PROPERTY(QFont appFont READ appFont NOTIFY fontsChanged)
    Q_PROPERTY(QFont cmdlineFont READ cmdlineFont NOTIFY fontsChanged)

  public:
    explicit ThemeHelper(QObject *parent = nullptr);
    ~ThemeHelper() override;

    int appearance() const noexcept;

    QColor windowColor() const;
    QColor windowTextColor() const;
    QColor baseColor() const;
    QColor alternateBaseColor() const;
    QColor lightColor() const;
    QColor midlightColor() const;
    QColor midColor() const;
    QColor darkColor() const;
    QColor shadowColor() const;
    QColor placeholderTextColor() const;
    QColor accentColor() const;
    QColor linkColor() const;
    QColor highlightColor() const;
    QColor highlightedTextColor() const;
    QColor textColor() const;
    QColor disabledTextColor() const;
    QColor buttonColor() const;
    QColor buttonTextColor() const;
    QColor buttonPressedColor() const;
    QColor buttonHoveredColor() const;
    QColor buttonDisabledColor() const;
    QColor chromeDividerColor() const;
    QColor navigationSurfaceColor() const;
    QColor commandSurfaceColor() const;
    QColor chatPageSurfaceColor() const;
    QColor chatContentSurfaceColor() const;
    QColor chatComposerSurfaceColor() const;
    QColor chatActionButtonColor() const;
    QColor chatActionButtonHoveredColor() const;
    QColor chatActionButtonPressedColor() const;
    QColor chatActionButtonBorderColor() const;

    QFont appFont() const;
    QFont cmdlineFont() const;

  Q_SIGNALS:
    void colorsChanged();
    void fontsChanged();

  private:
    QColor window_color_;
    QColor window_text_color_;
    QColor base_color_;
    QColor alternate_base_color_;
    QColor light_color_;
    QColor midlight_color_;
    QColor mid_color_;
    QColor dark_color_;
    QColor shadow_color_;
    QColor placeholder_text_color_;
    QColor accent_color_;
    QColor link_color_;
    QColor highlight_color_;
    QColor highlighted_text_color_;
    QColor text_color_;
    QColor disabled_text_color_;
    QColor button_color_;
    QColor button_text_color_;
    QColor button_pressed_color_;
    QColor button_hovered_color_;
    QColor button_disabled_color_;
    QColor chrome_divider_color_;
    QColor navigation_surface_color_;
    QColor command_surface_color_;
    QColor chat_page_surface_color_;
    QColor chat_content_surface_color_;
    QColor chat_composer_surface_color_;
    QColor chat_action_button_color_;
    QColor chat_action_button_hovered_color_;
    QColor chat_action_button_pressed_color_;
    QColor chat_action_button_border_color_;

    QFont app_font_;
    QFont cmdline_font_;
};
} // namespace geocontrols

#endif // CONTROLS_THEME_HELPER_H
