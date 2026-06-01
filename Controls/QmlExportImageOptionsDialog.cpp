#include "QmlExportImageOptionsDialog.h"

#include <QtCore/QDebug>
#include <QtCore/QEventLoop>
#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtCore/Qt>
#include <QtQml/QQmlComponent>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geocontrols
{
QmlExportImageOptionsDialog::QmlExportImageOptionsDialog(QObject *parent) : QObject(parent) {}

void QmlExportImageOptionsDialog::showDialog(QQuickView *view, const QString &title,
                                             const QString &initial_format,
                                             const QString &initial_mode, int initial_long_edge_px,
                                             bool initial_include_axis,
                                             bool initial_include_overlay_text,
                                             const ExportOptionsCallback &callback)
{
    if (!view)
    {
        qCritical() << "QmlExportImageOptionsDialog::showDialog view is null";
        ExportOptionsResult result;
        result.was_cancelled = true;
        if (callback)
        {
            callback(result);
        }
        return;
    }

    callback_ = callback;
    if (dialog_)
    {
        cleanupDialog();
    }

    dialog_ = createDialog(view, title, initial_format, initial_mode, initial_long_edge_px,
                           initial_include_axis, initial_include_overlay_text);
    if (!dialog_)
    {
        qCritical() << "QmlExportImageOptionsDialog::showDialog createDialog failed";
        ExportOptionsResult result;
        result.was_cancelled = true;
        invokeCallback(result);
        return;
    }

    const QMetaObject *meta_object = dialog_->metaObject();
    int method_index = meta_object->indexOfMethod("openDialog()");
    if (method_index != -1)
    {
        const bool ok = QMetaObject::invokeMethod(dialog_, "openDialog", Qt::QueuedConnection);
        if (!ok)
        {
            qWarning() << "QmlExportImageOptionsDialog::showDialog invoke openDialog failed";
        }
        return;
    }

    method_index = meta_object->indexOfMethod("open()");
    if (method_index != -1)
    {
        const bool ok = QMetaObject::invokeMethod(dialog_, "open", Qt::QueuedConnection);
        if (!ok)
        {
            qWarning() << "QmlExportImageOptionsDialog::showDialog invoke open failed";
        }
        return;
    }

    dialog_->setProperty("visible", true);
}

bool QmlExportImageOptionsDialog::isVisible() const
{
    return dialog_ && dialog_->property("visible").toBool();
}

void QmlExportImageOptionsDialog::close()
{
    if (dialog_)
    {
        QMetaObject::invokeMethod(dialog_, "close");
    }
}

QmlExportImageOptionsDialog::ExportOptionsResult
QmlExportImageOptionsDialog::getOptions(QQuickView *view, const QString &title,
                                        const QString &initial_format, const QString &initial_mode,
                                        int initial_long_edge_px, bool initial_include_axis,
                                        bool initial_include_overlay_text)
{
    QmlExportImageOptionsDialog dialog;
    QEventLoop loop;
    ExportOptionsResult result;
    result.was_cancelled = true;

    dialog.showDialog(view, title, initial_format, initial_mode, initial_long_edge_px,
                      initial_include_axis, initial_include_overlay_text,
                      [&result, &loop](const ExportOptionsResult &dialog_result)
                      {
                          result = dialog_result;
                          loop.quit();
                      });

    loop.exec();
    return result;
}

void QmlExportImageOptionsDialog::onOptionsAccepted(const QString &format, const QString &mode,
                                                    int long_edge_px, bool include_axis,
                                                    bool include_overlay_text)
{
    ExportOptionsResult result;
    result.format = format;
    result.mode = mode;
    result.long_edge_px = long_edge_px;
    result.include_axis = include_axis;
    result.include_overlay_text = include_overlay_text;
    result.was_cancelled = false;

    invokeCallback(result);
    cleanupDialog();
}

void QmlExportImageOptionsDialog::onCancelled()
{
    ExportOptionsResult result;
    result.was_cancelled = true;

    invokeCallback(result);
    cleanupDialog();
}

QObject *QmlExportImageOptionsDialog::createDialog(QQuickView *view, const QString &title,
                                                   const QString &initial_format,
                                                   const QString &initial_mode,
                                                   int initial_long_edge_px,
                                                   bool initial_include_axis,
                                                   bool initial_include_overlay_text)
{
    if (!view)
    {
        return nullptr;
    }
    QQmlEngine *const engine = view->engine();
    if (!engine)
    {
        return nullptr;
    }

    QQmlContext *const context = new QQmlContext(engine->rootContext());
    QQuickItem *const root_item = view->rootObject();
    if (root_item)
    {
        context->setContextProperty("parentItem", root_item);
    }

    QQmlComponent component(engine, QUrl("qrc:/GeoControls/QmlExportImageOptionsDialogPage.qml"));
    if (component.isError())
    {
        qCritical().noquote() << "QmlExportImageOptionsDialog::createDialog QML load failed:"
                              << component.errorString();
        delete context;
        return nullptr;
    }

    QObject *object = component.create(context);
    if (!object)
    {
        delete context;
        return nullptr;
    }

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(object, QQmlEngine::JavaScriptOwnership);
    context->setParent(object);

    object->setProperty("dialogTitle",
                        title.isEmpty() ? QStringLiteral("Export Image Options") : title);
    object->setProperty("initialFormat", initial_format);
    object->setProperty("initialMode", initial_mode);
    object->setProperty("initialLongEdgePx", initial_long_edge_px);
    object->setProperty("initialIncludeAxis", initial_include_axis);
    object->setProperty("initialIncludeOverlayText", initial_include_overlay_text);
    if (root_item)
    {
        object->setProperty("parentItem", QVariant::fromValue(root_item));
    }
    else if (view->contentItem())
    {
        object->setProperty("parentItem", QVariant::fromValue(view->contentItem()));
    }

    QObject::connect(object, SIGNAL(optionsAccepted(QString, QString, int, bool, bool)), this,
                     SLOT(onOptionsAccepted(QString, QString, int, bool, bool)));
    QObject::connect(object, SIGNAL(cancelled()), this, SLOT(onCancelled()));
    return object;
}

void QmlExportImageOptionsDialog::cleanupDialog()
{
    if (dialog_)
    {
        dialog_->deleteLater();
        dialog_ = nullptr;
    }
}

void QmlExportImageOptionsDialog::invokeCallback(const ExportOptionsResult &result)
{
    if (callback_)
    {
        callback_(result);
    }
}
} // namespace geocontrols
