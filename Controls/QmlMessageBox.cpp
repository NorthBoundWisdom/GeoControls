#include "QmlMessageBox.h"

#include <cassert>
#include <cstdlib>

#include <QtCore/QCoreApplication>
#include <QtCore/QEventLoop>
#include <QtCore/QObject>
#include <QtCore/QPointer>
#include <QtCore/QTimer>
#include <QtCore/QVariant>
#include <QtCore/Qt>
#include <QtCore/QtContainerFwd>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geotoys
{
static QPointer<QQuickView> dialog_host;

[[noreturn]] static void failFastMissingDialogHost()
{
    assert(false && "QmlMessageBox dialog host is not initialized");
    std::abort();
}

[[noreturn]] static void failFastMissingDialog()
{
    assert(false && "QmlMessageBox messageDialog object is not available");
    std::abort();
}

// No helper QObject needed; we'll read result from QML property after loop quits
static QObject *findDialog()
{
    QQuickView *view = dialog_host.data();
    if (!view)
    {
        failFastMissingDialogHost();
    }
    QQuickItem *root = qobject_cast<QQuickItem *>(view->rootObject());
    if (!root)
    {
        failFastMissingDialog();
    }
    if (QObject *dlg = root->findChild<QObject *>("messageDialog"))
    {
        return dlg;
    }
    failFastMissingDialog();
}

void QmlMessageBox::setDialogHost(QQuickView *view)
{
    dialog_host = view;
}

QmlMessageBox::Button QmlMessageBox::question(const QString &title, const QString &text,
                                              Buttons buttons, Button defaultButton)
{
    if (QObject *dlg = findDialog())
    {
        // Map our buttons to QML buttons
        // Translate button texts so they match QML's qsTr() translations
        // Context "MessageDialog" matches the context in .ts files
        QVariantList btns;
        if (buttons.testFlag(Button::Yes))
            btns << QVariant::fromValue(QCoreApplication::translate("MessageDialog", "Yes"));
        if (buttons.testFlag(Button::No))
            btns << QVariant::fromValue(QCoreApplication::translate("MessageDialog", "No"));
        if (buttons.testFlag(Button::Ok))
            btns << QVariant::fromValue(QCoreApplication::translate("MessageDialog", "OK"));
        if (buttons.testFlag(Button::Cancel))
            btns << QVariant::fromValue(QCoreApplication::translate("MessageDialog", "Cancel"));

        dlg->setProperty("titleText", title);
        dlg->setProperty("messageText", text);
        dlg->setProperty("buttons", btns);
        dlg->setProperty(
            "defaultButtonText",
            defaultButton == Button::Yes  ? QCoreApplication::translate("MessageDialog", "Yes")
            : defaultButton == Button::No ? QCoreApplication::translate("MessageDialog", "No")
            : defaultButton == Button::Ok ? QCoreApplication::translate("MessageDialog", "OK")
            : defaultButton == Button::Cancel
                ? QCoreApplication::translate("MessageDialog", "Cancel")
                : QString());

        // Use QEventLoop to wait for dialog result
        QEventLoop loop;
        Button result = Button::Invalid;
        QObject::connect(dlg, SIGNAL(finished(QString)), &loop, SLOT(quit()));

        // Defer dialog display until current event processing completes
        // This prevents blocking issues when called during viewer event handling
        // The dialog will be shown in the next event loop iteration
        QTimer::singleShot(
            0,
            [dlg]() { QMetaObject::invokeMethod(dlg, "openWithButtons", Qt::QueuedConnection); });

        // Wait for dialog to close
        // This blocks until the dialog's finished signal is emitted
        loop.exec();

        const QString ret = dlg->property("resultText").toString();
        // Compare with translated strings to match what QML returns
        const QString yesText = QCoreApplication::translate("MessageDialog", "Yes");
        const QString noText = QCoreApplication::translate("MessageDialog", "No");
        const QString okText = QCoreApplication::translate("MessageDialog", "OK");
        const QString cancelText = QCoreApplication::translate("MessageDialog", "Cancel");
        if (ret == yesText)
            result = Button::Yes;
        else if (ret == noText)
            result = Button::No;
        else if (ret == okText)
            result = Button::Ok;
        else if (ret == cancelText)
            result = Button::Cancel;
        return result;
    }
    failFastMissingDialog();
}

QmlMessageBox::Button QmlMessageBox::information(const QString &title, const QString &text,
                                                 Buttons buttons, Button defaultButton)
{
    // Reuse same dialog; typical info is OK only, but keep it generic
    return question(title, text, buttons, defaultButton);
}
} // namespace geotoys
