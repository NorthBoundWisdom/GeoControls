#ifndef GUI_CONTROLS_QML_MESSAGE_BOX_H
#define GUI_CONTROLS_QML_MESSAGE_BOX_H

#include <QtCore/QString>

class QQuickView;

namespace geotoys
{
class QmlMessageBox
{
public:
    enum class Button
    {
        Invalid = 0,
        Ok = 0x0001,
        Cancel = 0x0002,
        Yes = 0x0004,
        No = 0x0008
    };
    Q_DECLARE_FLAGS(Buttons, Button)

    static void setDialogHost(QQuickView *view);

    static Button question(const QString &title, const QString &text, Buttons buttons,
                           Button defaultButton = Button::No);

    static Button information(const QString &title, const QString &text,
                              Buttons buttons = Button::Ok, Button defaultButton = Button::Ok);
};

Q_DECLARE_OPERATORS_FOR_FLAGS(QmlMessageBox::Buttons)
} // namespace geotoys
#endif // GUI_CONTROLS_QML_MESSAGE_BOX_H
