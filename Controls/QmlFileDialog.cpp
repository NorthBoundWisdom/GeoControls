#include "QmlFileDialog.h"

#include <QtCore/QCoreApplication>
#include <QtCore/QDebug>
#include <QtCore/QEvent>
#include <QtCore/QEventLoop>
#include <QtCore/QFileInfo>
#include <QtCore/QObject>
#include <QtCore/QTimer>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtCore/Qt>
#include <QtCore/QtContainerFwd>
#include <QtQml/QQmlComponent>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geocontrols
{
QmlFileDialog::QmlFileDialog(QObject *parent) : QObject(parent) {}

QString QmlFileDialog::getOpenFileName(QQuickView *view, const QString &title, const QString &dir,
                                       const QString &filter, QString *selectedFilter)
{
    QmlFileDialog dialog;
    Result result = dialog.runDialog(view, DialogMode::OpenFile, title, dir, filter);
    if (selectedFilter)
    {
        *selectedFilter = result.selectedFilter;
    }
    return result.wasCancelled ? QString() : result.file;
}

QStringList QmlFileDialog::getOpenFileNames(QQuickView *view, const QString &title,
                                            const QString &dir, const QString &filter,
                                            QString *selectedFilter)
{
    QmlFileDialog dialog;
    Result result = dialog.runDialog(view, DialogMode::OpenFiles, title, dir, filter);
    if (selectedFilter)
    {
        *selectedFilter = result.selectedFilter;
    }
    return result.wasCancelled ? QStringList() : result.files;
}

QString QmlFileDialog::getSaveFileName(QQuickView *view, const QString &title, const QString &path,
                                       const QString &filter, QString *selectedFilter)
{
    QmlFileDialog dialog;
    Result result = dialog.runDialog(view, DialogMode::SaveFile, title, path, filter);
    if (selectedFilter)
    {
        *selectedFilter = result.selectedFilter;
    }
    return result.wasCancelled ? QString() : result.file;
}

QmlFileDialog::Result QmlFileDialog::runDialog(QQuickView *view, DialogMode mode,
                                               const QString &title, const QString &pathOrDir,
                                               const QString &filter)
{
    Result result;
    result.wasCancelled = true;

    if (!view)
    {
        qCritical() << "QmlFileDialog::runDialog view is null";
        return result;
    }

    QEventLoop loop;
    loop_ = &loop;
    result_ = result;

    dialog_ = createDialog(view, mode, title, pathOrDir, filter);
    if (!dialog_)
    {
        loop_ = nullptr;
        return result_;
    }

    QMetaObject::invokeMethod(dialog_, "openDialog", Qt::QueuedConnection);
    loop.exec();

    if (dialog_)
    {
        dialog_->deleteLater();
        dialog_ = nullptr;
    }
    // Ensure deferred destruction is processed before returning.
    QCoreApplication::sendPostedEvents(nullptr, QEvent::DeferredDelete);
    QCoreApplication::processEvents(QEventLoop::AllEvents, 10);

    loop_ = nullptr;
    return result_;
}

QObject *QmlFileDialog::createDialog(QQuickView *view, DialogMode mode, const QString &title,
                                     const QString &pathOrDir, const QString &filter)
{
    QQmlEngine *const engine = view->engine();
    QQmlContext *const context = new QQmlContext(engine->rootContext());

    QQuickItem *const root_item = view->rootObject();
    if (root_item)
    {
        context->setContextProperty("parentItem", root_item);
    }

    QQmlComponent component(engine, QUrl("qrc:/GeoControls/QmlFileDialogPage.qml"));
    if (component.isError())
    {
        for (const auto &err : component.errors())
        {
            qCritical().noquote() << "QmlFileDialog component error:" << err.toString();
        }
        delete context;
        return nullptr;
    }

    QObject *object = component.create(context);
    if (!object)
    {
        qCritical() << "QmlFileDialog component.create returned null";
        delete context;
        return nullptr;
    }

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
    context->setParent(object);

    object->setProperty("dialogTitle", title.isEmpty() ? QStringLiteral("Select File") : title);
    const QStringList nameFilters = parseNameFilters(filter);
    object->setProperty("nameFilters", QVariant::fromValue(nameFilters));

    QString mode_str = QStringLiteral("open");
    if (mode == DialogMode::SaveFile)
    {
        mode_str = QStringLiteral("save");
    }
    else if (mode == DialogMode::OpenFiles)
    {
        mode_str = QStringLiteral("openFiles");
    }
    object->setProperty("dialogMode", mode_str);

    if (!pathOrDir.isEmpty())
    {
        const QFileInfo info(pathOrDir);
        const bool treatAsDir = info.isDir() || pathOrDir.endsWith('/') || pathOrDir.endsWith('\\');
        if (treatAsDir)
        {
            object->setProperty("currentFolder", QUrl::fromLocalFile(info.absoluteFilePath()));
        }
        else
        {
            object->setProperty("currentFolder", QUrl::fromLocalFile(info.absolutePath()));
            if (mode == DialogMode::SaveFile)
            {
                object->setProperty("initialSelectedFile",
                                    QUrl::fromLocalFile(info.absoluteFilePath()));
            }
        }
    }

    QObject::connect(object, SIGNAL(fileAccepted(QString, QString, QVariant)), this,
                     SLOT(onFileAccepted(QString, QString, QVariant)));
    QObject::connect(object, SIGNAL(fileRejected()), this, SLOT(onFileRejected()));
    QObject::connect(object, SIGNAL(dialogClosed()), this, SLOT(onDialogClosed()));

    return object;
}

QStringList QmlFileDialog::parseNameFilters(const QString &filter)
{
    if (filter.isEmpty())
    {
        return {};
    }

    QStringList parts = filter.split(";;");
    for (QString &part : parts)
    {
        part = part.trimmed();
    }
    parts.removeAll(QString());
    return parts;
}

static QString normalizeFilePath(const QString &path)
{
    if (path.startsWith(QStringLiteral("file://")))
    {
        const QUrl url(path);
        if (url.isValid())
        {
            const QString local = url.toLocalFile();
            if (!local.isEmpty())
            {
                return local;
            }
        }
    }
    return path;
}

void QmlFileDialog::onFileAccepted(const QString &filePath, const QString &selectedFilter,
                                   const QVariant &filePaths)
{
    result_.file = normalizeFilePath(filePath);
    result_.files.clear();
    if (filePaths.canConvert<QVariantList>())
    {
        const QVariantList list = filePaths.toList();
        result_.files.reserve(list.size());
        for (const auto &entry : list)
        {
            result_.files.push_back(normalizeFilePath(entry.toString()));
        }
    }
    else
    {
        const QString single = normalizeFilePath(filePaths.toString());
        if (!single.isEmpty())
        {
            result_.files.push_back(single);
        }
    }
    if (result_.file.isEmpty() && !result_.files.isEmpty())
    {
        result_.file = result_.files.front();
    }
    result_.selectedFilter = selectedFilter;
    result_.wasCancelled = false;
    if (dialog_)
    {
        QMetaObject::invokeMethod(dialog_, "closeDialog", Qt::QueuedConnection);
    }
}

void QmlFileDialog::onFileRejected()
{
    result_.wasCancelled = true;
    if (dialog_)
    {
        QMetaObject::invokeMethod(dialog_, "closeDialog", Qt::QueuedConnection);
    }
}

void QmlFileDialog::onDialogClosed()
{
    if (loop_)
    {
        loop_->quit();
    }
}
} // namespace geocontrols
