#include "QmlListDialog.h"

#include <functional>

#include <QtCore/QDebug>
#include <QtCore/QEventLoop>
#include <QtCore/QList>
#include <QtCore/QObject>
#include <QtCore/QPointer>
#include <QtCore/QTimer>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtCore/Qt>
#include <QtCore/QtContainerFwd>
#include <QtQml/QQmlComponent>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlError>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geocontrols
{
namespace
{
void requestDialogActivation(QQuickView *view, QObject *dialog)
{
    if (!view)
    {
        return;
    }

    view->raise();
    view->requestActivate();

    if (dialog)
    {
        QMetaObject::invokeMethod(dialog, "requestDialogFocus", Qt::QueuedConnection);
        QMetaObject::invokeMethod(dialog, "requestInitialFocus", Qt::QueuedConnection);
    }
}
} // namespace

QmlListDialog::QmlListDialog(QObject *parent) : QObject(parent) {}

void QmlListDialog::showListDialog(QQuickView *view, const QStringList &items, const QString &title,
                                   bool allow_multiple_selection, const SelectionCallback &callback)
{
    qDebug() << "QmlListDialog::showListDialog" << title << items.size()
             << allow_multiple_selection;
    callback_ = callback;
    allowMultipleSelection_ = allow_multiple_selection;

    if (dialog_)
    {
        cleanupDialog();
    }

    dialog_ = createDialog(view, items, title, allow_multiple_selection);
    if (dialog_)
    {
        // Check if the dialog has the open method
        const QMetaObject *metaObject = dialog_->metaObject();
        const int method_index = metaObject->indexOfMethod("open()");
        if (method_index != -1)
        {
            QMetaObject::invokeMethod(dialog_, "open");
        }
        else
        {
            // Fallback: try to set visible property
            dialog_->setProperty("visible", true);
        }

        QPointer<QQuickView> safe_view(view);
        QPointer<QObject> safe_dialog(dialog_);
        requestDialogActivation(safe_view.data(), safe_dialog.data());
        QTimer::singleShot(0, this, [safe_view, safe_dialog]()
                           { requestDialogActivation(safe_view.data(), safe_dialog.data()); });
        QTimer::singleShot(16, this, [safe_view, safe_dialog]()
                           { requestDialogActivation(safe_view.data(), safe_dialog.data()); });
        QTimer::singleShot(50, this, [safe_view, safe_dialog]()
                           { requestDialogActivation(safe_view.data(), safe_dialog.data()); });
    }
    else
    {
        qCritical() << "QmlListDialog::showListDialog failed to create dialog" << view
                    << (view ? view->rootObject() : nullptr);
    }
}

void QmlListDialog::showSingleSelectionDialog(QQuickView *view, const QStringList &items,
                                              const QString &title,
                                              const std::function<void(const QString &)> &callback)
{
    showListDialog(view, items, title, false,
                   [callback](const SelectionInfo &result)
                   {
                       if (callback)
                       {
                           callback(result.wasCancelled ? QString() : result.selectedItem);
                       }
                   });
}

void QmlListDialog::showMultipleSelectionDialog(
    QQuickView *view, const QStringList &items, const QString &title,
    const std::function<void(const QStringList &)> &callback)
{
    showListDialog(view, items, title, true,
                   [callback](const SelectionInfo &result)
                   {
                       if (callback)
                       {
                           callback(result.wasCancelled ? QStringList() : result.selectedItems);
                       }
                   });
}

bool QmlListDialog::isVisible() const
{
    return dialog_ && dialog_->property("visible").toBool();
}

void QmlListDialog::close()
{
    if (dialog_)
    {
        QMetaObject::invokeMethod(dialog_, "close");
    }
}

QObject *QmlListDialog::createDialog(QQuickView *view, const QStringList &items,
                                     const QString &title, bool allow_multiple_selection)
{
    if (!view)
    {
        qCritical() << "QmlListDialog::createDialog view is null";
        return nullptr;
    }
    QQmlEngine *const engine = view->engine();
    QQmlContext *const context = new QQmlContext(engine->rootContext());

    // Set the root item as parent for the popup
    QQuickItem *const root_item = view->rootObject();
    if (root_item)
    {
        context->setContextProperty("parentItem", root_item);
    }
    else
    {
        qCritical() << "QmlListDialog::createDialog view has no rootObject";
    }

    QQmlComponent component(engine, QUrl("qrc:/GeoControls/QmlListDialogPage.qml"));
    if (component.isError())
    {
        const auto errors = component.errors();
        for (const auto &err : errors)
        {
            qCritical().noquote() << "QmlListDialog QML component error:" << err.toString();
        }
        delete context;
        return nullptr;
    }

    QObject *object = component.create(context);
    if (!object)
    {
        qCritical() << "QmlListDialog component.create returned null";
        delete context;
        return nullptr;
    }

    // Set ownership
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(object, QQmlEngine::JavaScriptOwnership);
    context->setParent(object);

    // After creating the object, set properties directly
    if (root_item)
    {
        object->setProperty("parentItem", QVariant::fromValue(root_item));
    }
    object->setProperty("dialogTitle", title.isEmpty() ? "Select Item" : title);
    object->setProperty("dialogItems", QVariant::fromValue(items));
    object->setProperty("allowMultipleSelection", allow_multiple_selection);

    // Test if we can call a method on the object
    QMetaObject::invokeMethod(object, "openDialog", Qt::QueuedConnection);

    // Connect signals based on selection mode
    if (allow_multiple_selection)
    {
        QObject::connect(object, SIGNAL(itemsSelected(QStringList, QList<int>)), this,
                         SLOT(onItemsSelected(QStringList, QList<int>)));
    }
    else
    {
        QObject::connect(object, SIGNAL(itemSelected(QString, int)), this,
                         SLOT(onItemSelected(QString, int)));
    }
    QObject::connect(object, SIGNAL(cancelled()), this, SLOT(onCancelled()));

    return object;
}

void QmlListDialog::cleanupDialog()
{
    if (dialog_)
    {
        dialog_->deleteLater();
        dialog_ = nullptr;
    }
}

void QmlListDialog::onItemSelected(const QString &item, int index)
{
    SelectionInfo result;
    result.selectedItem = item;
    result.selectedIndex = index;
    result.wasCancelled = false;

    invokeCallback(result);
    cleanupDialog();
}

void QmlListDialog::onItemsSelected(const QStringList &items, const QList<int> &indices)
{
    SelectionInfo result;
    result.selectedItems = items;
    result.selectedIndices = indices;
    result.selectedItem = items.isEmpty() ? QString() : items.first();
    result.selectedIndex = indices.isEmpty() ? -1 : indices.first();
    result.wasCancelled = false;

    invokeCallback(result);
    cleanupDialog();
}

void QmlListDialog::onCancelled()
{
    SelectionInfo result;
    result.wasCancelled = true;

    invokeCallback(result);
    cleanupDialog();
}

void QmlListDialog::invokeCallback(const SelectionInfo &result)
{
    if (callback_)
    {
        callback_(result);
    }
}

QString QmlListDialog::getItem(QQuickView *view, const QStringList &items, const QString &title,
                               const QString &defaultItem)
{
    if (!view)
    {
        qCritical() << "QmlListDialog::getItem view is null, returning default";
        return defaultItem;
    }

    // Create a temporary dialog instance for synchronous operation
    QmlListDialog dialog;

    QString result;
    QEventLoop loop;

    // Use the existing showSingleSelectionDialog with a callback that sets the result and quits the
    // loop
    dialog.showSingleSelectionDialog(view, items, title,
                                     [&result, &loop](const QString &selectedItem)
                                     {
                                         result = selectedItem;
                                         loop.quit();
                                     });

    // Wait for the dialog to complete
    loop.exec();

    return result;
}
} // namespace geocontrols
