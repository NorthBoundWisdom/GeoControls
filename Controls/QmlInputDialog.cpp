#include "QmlInputDialog.h"

#include <functional>

#include <QtCore/QDebug>
#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtCore/Qt>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geocontrols
{
QmlInputDialog::QmlInputDialog(QObject *parent) : QObject(parent) {}

void QmlInputDialog::showInputDialog(QQuickView *view, const QString &title,
                                     const QString &placeholder_text, const QString &initial_text,
                                     const InputCallback &callback)
{
    if (!view)
    {
        qCritical() << "QmlInputDialog::showInputDialog: view is null";
        return;
    }

    callback_ = callback;

    if (dialog_)
    {
        cleanupDialog();
    }

    dialog_ = createDialog(view, title, placeholder_text, initial_text);
    if (dialog_)
    {
        // Check if the dialog has the openDialog method (preferred)
        const QMetaObject *metaObject = dialog_->metaObject();
        int method_index = metaObject->indexOfMethod("openDialog()");
        if (method_index != -1)
        {
            const bool success =
                QMetaObject::invokeMethod(dialog_, "openDialog", Qt::QueuedConnection);
            if (!success)
            {
                qWarning() << "QmlInputDialog::showInputDialog: failed to invoke openDialog()";
            }
        }
        else
        {
            // Fallback: try open() method
            method_index = metaObject->indexOfMethod("open()");
            if (method_index != -1)
            {
                const bool success =
                    QMetaObject::invokeMethod(dialog_, "open", Qt::QueuedConnection);
                if (!success)
                {
                    qWarning() << "QmlInputDialog::showInputDialog: failed to invoke open()";
                }
            }
            else
            {
                // Last resort: try to set visible property
                dialog_->setProperty("visible", true);
                qWarning() << "QmlInputDialog::showInputDialog: using visible property fallback";
            }
        }
    }
    else
    {
        qCritical() << "QmlInputDialog::showInputDialog: failed to create dialog";
    }
}

void QmlInputDialog::showTextInputDialog(QQuickView *view, const QString &title,
                                         const QString &placeholder_text,
                                         const QString &initial_text,
                                         const std::function<void(const QString &)> &callback)
{
    showInputDialog(view, title, placeholder_text, initial_text,
                    [callback](const InputResult &result)
                    {
                        if (callback)
                        {
                            callback(result.wasCancelled ? QString() : result.inputText);
                        }
                    });
}

bool QmlInputDialog::isVisible() const
{
    return dialog_ && dialog_->property("visible").toBool();
}

void QmlInputDialog::close()
{
    if (dialog_)
    {
        QMetaObject::invokeMethod(dialog_, "close");
    }
}

QObject *QmlInputDialog::createDialog(QQuickView *view, const QString &title,
                                      const QString &placeholder_text, const QString &initial_text)
{
    if (!view)
    {
        qCritical() << "QmlInputDialog::createDialog: view is null";
        return nullptr;
    }

    QQmlEngine *const engine = view->engine();
    if (!engine)
    {
        qCritical() << "QmlInputDialog::createDialog: engine is null";
        return nullptr;
    }

    QQmlContext *const context = new QQmlContext(engine->rootContext());

    // Set the root item as parent for the popup
    QQuickItem *const root_item = view->rootObject();
    if (root_item)
    {
        context->setContextProperty("parentItem", root_item);
    }
    else
    {
        qWarning() << "QmlInputDialog::createDialog: rootObject is null";
    }

    QQmlComponent component(engine, QUrl("qrc:/GeoControls/QmlInputDialogPage.qml"));
    if (component.isError())
    {
        qCritical().noquote() << "QmlInputDialog::createDialog: failed to load QML component:"
                              << component.errorString();
        delete context;
        return nullptr;
    }

    QObject *object = component.create(context);
    if (!object)
    {
        qCritical() << "QmlInputDialog::createDialog: failed to create QML object";
        delete context;
        return nullptr;
    }

    // Set ownership
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(object, QQmlEngine::JavaScriptOwnership);
    context->setParent(object);

    // After creating the object, set properties directly
    object->setProperty("dialogTitle", title.isEmpty() ? "Input Text" : title);
    object->setProperty("placeholderText", placeholder_text);
    object->setProperty("initialText", initial_text);
    if (root_item)
    {
        object->setProperty("parentItem", QVariant::fromValue(root_item));
    }
    else if (view->contentItem())
    {
        object->setProperty("parentItem", QVariant::fromValue(view->contentItem()));
    }

    // Connect signals
    const bool connected_1 = QObject::connect(object, SIGNAL(textSubmitted(QString)), this,
                                              SLOT(onTextSubmitted(QString)));
    const bool connected_2 =
        QObject::connect(object, SIGNAL(cancelled()), this, SLOT(onCancelled()));

    if (!connected_1 || !connected_2)
    {
        qWarning() << "QmlInputDialog::createDialog: failed to connect some signals";
    }

    // Try to cast to QQuickItem to check if it's a valid item
    QQuickItem *const item = qobject_cast<QQuickItem *>(object);
    if (!item)
    {
        qWarning() << "QmlInputDialog::createDialog: dialog is not a QQuickItem";
    }
    return object;
}

void QmlInputDialog::cleanupDialog()
{
    if (dialog_)
    {
        dialog_->deleteLater();
        dialog_ = nullptr;
    }
}

void QmlInputDialog::invokeCallback(const InputResult &result)
{
    if (callback_)
    {
        callback_(result);
    }
}

void QmlInputDialog::onTextSubmitted(const QString &text)
{
    InputResult result;
    result.inputText = text;
    result.wasCancelled = false;

    invokeCallback(result);
    cleanupDialog();
}

void QmlInputDialog::onCancelled()
{
    InputResult result;
    result.inputText = QString();
    result.wasCancelled = true;

    invokeCallback(result);
    cleanupDialog();
}
} // namespace geocontrols
