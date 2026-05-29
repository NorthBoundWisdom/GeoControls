#ifndef GUI_CUSTOMQML_QML_KEY_VALUE_DIALOG_H
#define GUI_CUSTOMQML_QML_KEY_VALUE_DIALOG_H

#include <functional>
#include <string>
#include <utility>
#include <vector>

#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geotoys
{
/*!
 * \brief A QML-based dialog for editing key-value pairs
 *
 * This class provides a reusable dialog for editing a list of name-value pairs.
 * Users can modify the values while the names are read-only.
 */
class QmlKeyValueDialog : public QObject
{
    Q_OBJECT

public:
    struct KeyValuePair
    {
        QString name;
        QVariant value;
    };

    struct KeyValueResult
    {
        std::vector<std::pair<std::string, QVariant>> keyValueList; //!< The edited key-value pairs
        bool wasCancelled = false; //!< Whether the dialog was cancelled
    };

    using KeyValueCallback = std::function<void(const KeyValueResult &)>;

    explicit QmlKeyValueDialog(QObject *parent = nullptr);
    ~QmlKeyValueDialog() override = default;

    /*!
     * \brief Show a key-value editing dialog
     * \param view The QQuickView to attach the dialog to
     * \param title Optional dialog title
     * \param keyValueList List of name-value pairs to edit
     * \param callback Function to call when values are submitted or dialog is cancelled
     */
    void
    showKeyValueDialog(QQuickView *view, const QString &title = QString(),
                       const std::vector<std::pair<std::string, QVariant>> &key_value_list = {},
                       const KeyValueCallback &callback = nullptr);

    /*!
     * \brief Convenience method for simple key-value editing
     * \param view The QQuickView to attach the dialog to
     * \param title Optional dialog title
     * \param keyValueList List of name-value pairs to edit
     * \param callback Function to call with the edited key-value pairs (empty if cancelled)
     */
    void showKeyValueEditDialog(
        QQuickView *view, const QString &title = QString(),
        const std::vector<std::pair<std::string, QVariant>> &key_value_list = {},
        const std::function<void(const std::vector<std::pair<std::string, QVariant>> &)> &callback =
            nullptr);

    bool isVisible() const;
    void close();

private slots:
    void onValuesSubmitted(const QVariant &key_value_list);
    void onCancelled();

private:
    QObject *createDialog(QQuickView *view, const QString &title,
                          const std::vector<std::pair<std::string, QVariant>> &key_value_list);
    void cleanupDialog();
    void invokeCallback(const KeyValueResult &result);
    QVariantList
    convertToQVariantList(const std::vector<std::pair<std::string, QVariant>> &key_value_list);
    std::vector<std::pair<std::string, QVariant>>
    convertFromQVariantList(const QVariantList &variantList);

private:
    QObject *dialog_ = nullptr;
    KeyValueCallback callback_;
};
} // namespace geotoys
#endif // GUI_CUSTOMQML_QML_KEY_VALUE_DIALOG_H
