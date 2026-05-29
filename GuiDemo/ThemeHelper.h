#ifndef GUIDEMO_THEME_HELPER_H
#define GUIDEMO_THEME_HELPER_H

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtGui/QFont>
#include <QtGui/QFontMetrics>

namespace networkutil
{
class ThemeHelper : public QObject
{
    Q_OBJECT

public:
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

    /*Fonts*/
    Q_PROPERTY(QFont appFont READ appFont NOTIFY fontsChanged)
    Q_PROPERTY(QFont cmdlineFont READ cmdlineFont NOTIFY fontsChanged)

public:
    ThemeHelper(QObject *parent = nullptr);
    ~ThemeHelper() override;

    /*Colors*/
    QColor windowColor() const;
    QColor windowTextColor() const;
    QColor baseColor() const;
    QColor alternateBaseColor() const;
    QColor textColor() const;
    QColor buttonColor() const;
    QColor buttonTextColor() const;
    QColor lightColor() const;
    QColor midlightColor() const;
    QColor darkColor() const;
    QColor midColor() const;
    QColor shadowColor() const;
    QColor highlightColor() const;
    QColor highlightedTextColor() const;
    QColor linkColor() const;
    QColor placeholderTextColor() const;
    QColor accentColor() const;
    QColor disabledTextColor() const;
    QColor buttonPressedColor() const;
    QColor buttonHoveredColor() const;
    QColor buttonDisabledColor() const;

    /*Fonts*/
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
    QColor text_color_;
    QColor button_color_;
    QColor button_text_color_;
    QColor light_color_;
    QColor midlight_color_;
    QColor dark_color_;
    QColor mid_color_;
    QColor shadow_color_;
    QColor highlight_color_;
    QColor highlighted_text_color_;
    QColor link_color_;
    QColor placeholder_text_color_;
    QColor accent_color_;
    QColor disabled_text_color_;
    QColor button_pressed_color_;
    QColor button_hovered_color_;
    QColor button_disabled_color_;

    QFont app_font_;
    QFont cmdline_font_;
};
} // namespace networkutil
#endif // GUIDEMO_THEME_HELPER_H
