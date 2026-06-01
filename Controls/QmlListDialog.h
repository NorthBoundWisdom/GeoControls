#ifndef GEOCONTROLS_QML_LIST_DIALOG_H
#define GEOCONTROLS_QML_LIST_DIALOG_H

#include <functional>

#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geocontrols
{
/*!
 * \brief A generic QML-based list selection dialog
 *
 * This class provides a reusable dialog for selecting items from a list.
 * It supports both single and multiple selection modes, and provides
 * flexible callback mechanisms for handling user interactions.
 */
class QmlListDialog : public QObject
{
    Q_OBJECT

  public:
    struct SelectionInfo
    {
        QString selectedItem;       //!< The selected item text
        int selectedIndex = -1;     //!< The selected item index (0-based)
        QStringList selectedItems;  //!< Multiple selected items (for multi-select mode)
        QList<int> selectedIndices; //!< Multiple selected indices (for multi-select mode)
        bool wasCancelled = false;  //!< Whether the dialog was cancelled
    };

    using SelectionCallback = std::function<void(const SelectionInfo &)>;

    explicit QmlListDialog(QObject *parent = nullptr);
    ~QmlListDialog() override = default;

    /*!
     * \brief Show a list selection dialog
     * \param view The QQuickView to attach the dialog to
     * \param items The list of items to display
     * \param title Optional dialog title
     * \param allowMultipleSelection Whether to allow multiple item selection
     * \param callback Function to call when selection is made or dialog is cancelled
     */
    void showListDialog(QQuickView *view, const QStringList &items,
                        const QString &title = QString(), bool allow_multiple_selection = false,
                        const SelectionCallback &callback = nullptr);

    /*!
     * \brief Convenience method for single item selection
     * \param view The QQuickView to attach the dialog to
     * \param items The list of items to display
     * \param title Optional dialog title
     * \param callback Function to call with the selected item (empty string if cancelled)
     */
    void showSingleSelectionDialog(QQuickView *view, const QStringList &items,
                                   const QString &title = QString(),
                                   const std::function<void(const QString &)> &callback = nullptr);

    /*!
     * \brief Convenience method for multiple item selection
     * \param view The QQuickView to attach the dialog to
     * \param items The list of items to display
     * \param title Optional dialog title
     * \param callback Function to call with the selected items (empty list if cancelled)
     */
    void
    showMultipleSelectionDialog(QQuickView *view, const QStringList &items,
                                const QString &title = QString(),
                                const std::function<void(const QStringList &)> &callback = nullptr);

    /*!
     * \brief Check if the dialog is currently visible
     */
    bool isVisible() const;

    /*!
     * \brief Close the dialog programmatically
     */
    void close();

    /*!
     * \brief Static method for synchronous list selection (similar to QInputDialog)
     * \param items The list of items to display
     * \param title Optional dialog title
     * \param defaultItem Optional default selected item
     * \return The selected item, or empty string if cancelled
     */
    static QString getItem(QQuickView *view, const QStringList &items,
                           const QString &title = QString(),
                           const QString &defaultItem = QString());

  private slots:
    void onItemSelected(const QString &item, int index);
    void onItemsSelected(const QStringList &items, const QList<int> &indices);
    void onCancelled();

  private:
    QObject *createDialog(QQuickView *view, const QStringList &items, const QString &title,
                          bool allow_multiple_selection);
    void cleanupDialog();
    void invokeCallback(const SelectionInfo &result);

  private:
    QObject *dialog_ = nullptr;
    SelectionCallback callback_;
    bool allowMultipleSelection_ = false;
};
} // namespace geocontrols
#endif // GEOCONTROLS_QML_LIST_DIALOG_H
