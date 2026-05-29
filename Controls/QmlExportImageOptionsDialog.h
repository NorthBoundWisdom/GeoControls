#ifndef GUI_CUSTOMQML_QML_EXPORT_IMAGE_OPTIONS_DIALOG_H
#define GUI_CUSTOMQML_QML_EXPORT_IMAGE_OPTIONS_DIALOG_H

#include <functional>

#include <QtQuick/QQuickView>

namespace geotoys
{
class QmlExportImageOptionsDialog : public QObject
{
    Q_OBJECT

  public:
    struct ExportOptionsResult
    {
        QString format;
        QString mode;
        int long_edge_px = -1;
        bool include_axis = false;
        bool include_overlay_text = false;
        bool was_cancelled = false;
    };

    using ExportOptionsCallback = std::function<void(const ExportOptionsResult &)>;

    explicit QmlExportImageOptionsDialog(QObject *parent = nullptr);
    ~QmlExportImageOptionsDialog() override = default;

    void showDialog(QQuickView *view, const QString &title, const QString &initial_format,
                    const QString &initial_mode, int initial_long_edge_px,
                    bool initial_include_axis, bool initial_include_overlay_text,
                    const ExportOptionsCallback &callback = nullptr);

    bool isVisible() const;
    void close();

    static ExportOptionsResult getOptions(QQuickView *view, const QString &title,
                                          const QString &initial_format,
                                          const QString &initial_mode, int initial_long_edge_px,
                                          bool initial_include_axis,
                                          bool initial_include_overlay_text);

  private slots:
    void onOptionsAccepted(const QString &format, const QString &mode, int long_edge_px,
                           bool include_axis, bool include_overlay_text);
    void onCancelled();

  private:
    QObject *createDialog(QQuickView *view, const QString &title, const QString &initial_format,
                          const QString &initial_mode, int initial_long_edge_px,
                          bool initial_include_axis, bool initial_include_overlay_text);
    void cleanupDialog();
    void invokeCallback(const ExportOptionsResult &result);

  private:
    QObject *dialog_ = nullptr;
    ExportOptionsCallback callback_;
};
} // namespace geotoys

#endif // GUI_CUSTOMQML_QML_EXPORT_IMAGE_OPTIONS_DIALOG_H
