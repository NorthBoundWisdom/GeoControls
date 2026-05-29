#ifndef GUI_CUSTOMQML_QML_FILE_DIALOG_H
#define GUI_CUSTOMQML_QML_FILE_DIALOG_H

#include <QtCore/QEventLoop>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>

class QQuickView;

namespace geotoys
{
class QmlFileDialog : public QObject
{
    Q_OBJECT

  public:
    enum class DialogMode
    {
        OpenFile,
        OpenFiles,
        SaveFile
    };

    struct Result
    {
        QString file;
        QStringList files;
        QString selectedFilter;
        bool wasCancelled = true;
    };

    static QString getOpenFileName(QQuickView *view, const QString &title, const QString &dir,
                                   const QString &filter, QString *selectedFilter = nullptr);

    static QStringList getOpenFileNames(QQuickView *view, const QString &title, const QString &dir,
                                        const QString &filter, QString *selectedFilter = nullptr);

    static QString getSaveFileName(QQuickView *view, const QString &title, const QString &path,
                                   const QString &filter, QString *selectedFilter = nullptr);

  private:
    explicit QmlFileDialog(QObject *parent = nullptr);

    Result runDialog(QQuickView *view, DialogMode mode, const QString &title,
                     const QString &pathOrDir, const QString &filter);

    QObject *createDialog(QQuickView *view, DialogMode mode, const QString &title,
                          const QString &pathOrDir, const QString &filter);

    static QStringList parseNameFilters(const QString &filter);

  private slots:
    void onFileAccepted(const QString &filePath, const QString &selectedFilter,
                        const QVariant &filePaths);
    void onFileRejected();
    void onDialogClosed();

  private:
    QObject *dialog_ = nullptr;
    QEventLoop *loop_ = nullptr;
    Result result_;
};
} // namespace geotoys

#endif // GUI_CUSTOMQML_QML_FILE_DIALOG_H
