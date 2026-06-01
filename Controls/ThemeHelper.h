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
    Q_PROPERTY(QColor dividerColor READ dividerColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor railSurfaceColor READ railSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor inputSurfaceColor READ inputSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor pageSurfaceColor READ pageSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor contentSurfaceColor READ contentSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor popupSurfaceColor READ popupSurfaceColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor actionButtonColor READ actionButtonColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor actionButtonHoveredColor READ actionButtonHoveredColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor actionButtonPressedColor READ actionButtonPressedColor NOTIFY colorsChanged)
    Q_PROPERTY(QColor actionButtonBorderColor READ actionButtonBorderColor NOTIFY colorsChanged)

    Q_PROPERTY(QFont appFont READ appFont NOTIFY fontsChanged)
    Q_PROPERTY(QFont monoFont READ monoFont NOTIFY fontsChanged)

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
    QColor dividerColor() const;
    QColor railSurfaceColor() const;
    QColor inputSurfaceColor() const;
    QColor pageSurfaceColor() const;
    QColor contentSurfaceColor() const;
    QColor popupSurfaceColor() const;
    QColor actionButtonColor() const;
    QColor actionButtonHoveredColor() const;
    QColor actionButtonPressedColor() const;
    QColor actionButtonBorderColor() const;

    QFont appFont() const;
    QFont monoFont() const;

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
    QColor divider_color_;
    QColor rail_surface_color_;
    QColor input_surface_color_;
    QColor page_surface_color_;
    QColor content_surface_color_;
    QColor popup_surface_color_;
    QColor action_button_color_;
    QColor action_button_hovered_color_;
    QColor action_button_pressed_color_;
    QColor action_button_border_color_;

    QFont app_font_;
    QFont mono_font_;
};
} // namespace geocontrols

#endif // CONTROLS_THEME_HELPER_H
