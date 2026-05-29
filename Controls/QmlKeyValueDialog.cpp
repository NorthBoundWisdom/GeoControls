#include "QmlKeyValueDialog.h"

#include <functional>
#include <string>
#include <utility>
#include <vector>

#include <QtCore/QObject>
#include <QtCore/QVariant>
#include <QtCore/QtContainerFwd>
#include <QtQml/QQmlComponent>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geotoys
{
QmlKeyValueDialog::QmlKeyValueDialog(QObject *parent)
    : QObject(parent)
{
}

void QmlKeyValueDialog::showKeyValueDialog(
    QQuickView *view, const QString &title,
    const std::vector<std::pair<std::string, QVariant>> &key_value_list,
    const KeyValueCallback &callback)
{
    callback_ = callback;

    if (dialog_)
    {
        cleanupDialog();
    }

    dialog_ = createDialog(view, title, key_value_list);
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
    }
}

void QmlKeyValueDialog::showKeyValueEditDialog(
    QQuickView *view, const QString &title,
    const std::vector<std::pair<std::string, QVariant>> &key_value_list,
    const std::function<void(const std::vector<std::pair<std::string, QVariant>> &)> &callback)
{
    showKeyValueDialog(view, title, key_value_list,
                       [callback](const KeyValueResult &result)
                       {
                           if (callback && !result.wasCancelled)
                           {
                               callback(result.keyValueList);
                           }
                       });
}

bool QmlKeyValueDialog::isVisible() const
{
    return dialog_ && dialog_->property("visible").toBool();
}

void QmlKeyValueDialog::close()
{
    if (dialog_)
    {
        QMetaObject::invokeMethod(dialog_, "close");
    }
}

QObject *
QmlKeyValueDialog::createDialog(QQuickView *view, const QString &title,
                                const std::vector<std::pair<std::string, QVariant>> &key_value_list)
{
    QQmlEngine *const engine = view->engine();
    QQmlContext *const context = new QQmlContext(engine->rootContext());
    // Expose this C++ dialog object to QML as a context property
    context->setContextProperty("keyValueDialog", this);

    // Set the root item as parent for the popup
    QQuickItem *const root_item = view->rootObject();
    if (root_item)
    {
        context->setContextProperty("parentItem", root_item);
    }

    QQmlComponent component(engine, QUrl("qrc:/GeoToy/Controls/QmlKeyValueDialogPage.qml"));
    if (component.isError())
    {
        delete context;
        return nullptr;
    }

    QObject *object = component.create(context);
    if (!object)
    {
        delete context;
        return nullptr;
    }

    // Set ownership
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(object, QQmlEngine::JavaScriptOwnership);
    context->setParent(object);

    // After creating the object, set properties directly
    object->setProperty("dialogTitle", title.isEmpty() ? "Edit Properties" : title);
    const QVariantList converted_list = convertToQVariantList(key_value_list);
    object->setProperty("keyValueList", converted_list);

    // Test if we can call a method on the object
    QMetaObject::invokeMethod(object, "openDialog");

    // Connect signals
    (void)QObject::connect(object, SIGNAL(valuesSubmitted(QVariant)), this,
                           SLOT(onValuesSubmitted(QVariant)));
    (void)QObject::connect(object, SIGNAL(cancelled()), this, SLOT(onCancelled()));

    return object;
}

void QmlKeyValueDialog::cleanupDialog()
{
    if (dialog_)
    {
        dialog_->deleteLater();
        dialog_ = nullptr;
    }
}

void QmlKeyValueDialog::invokeCallback(const KeyValueResult &result)
{
    if (callback_)
    {
        callback_(result);
    }
}

void QmlKeyValueDialog::onValuesSubmitted(const QVariant &key_value_list)
{
    KeyValueResult result;
    result.keyValueList = convertFromQVariantList(key_value_list.toList());
    result.wasCancelled = false;

    invokeCallback(result);
    cleanupDialog();
}

void QmlKeyValueDialog::onCancelled()
{
    KeyValueResult result;
    result.keyValueList.clear();
    result.wasCancelled = true;

    invokeCallback(result);
    cleanupDialog();
}

QVariantList QmlKeyValueDialog::convertToQVariantList(
    const std::vector<std::pair<std::string, QVariant>> &key_value_list)
{
    QVariantList variant_list;
    for (const auto &pair : key_value_list)
    {
        QVariantMap map;
        map["name"] = QString::fromStdString(pair.first);
        map["value"] = pair.second;
        variant_list.append(map);
    }
    return variant_list;
}

std::vector<std::pair<std::string, QVariant>>
QmlKeyValueDialog::convertFromQVariantList(const QVariantList &variantList)
{
    std::vector<std::pair<std::string, QVariant>> key_value_list;
    for (const QVariant &variant : variantList)
    {
        const QVariantMap map = variant.toMap();
        const std::string name = map["name"].toString().toStdString();
        const QVariant value = map["value"];
        key_value_list.emplace_back(name, value);
    }
    return key_value_list;
}
} // namespace geotoys
