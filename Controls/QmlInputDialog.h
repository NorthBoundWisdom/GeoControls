#ifndef GEOCONTROLS_QML_INPUT_DIALOG_H
#define GEOCONTROLS_QML_INPUT_DIALOG_H

#include <functional>

#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>

namespace geocontrols
{
/*!
 * \brief A generic QML-based input dialog
 *
 * This class provides a reusable dialog for text input with OK and Cancel buttons.
 * It supports various input modes and provides flexible callback mechanisms for handling user
 * interactions.
 */
class QmlInputDialog : public QObject
{
    Q_OBJECT

  public:
    struct InputResult
    {
        QString inputText;         //!< The input text
        bool wasCancelled = false; //!< Whether the dialog was cancelled
    };

    using InputCallback = std::function<void(const InputResult &)>;

    explicit QmlInputDialog(QObject *parent = nullptr);
    ~QmlInputDialog() override = default;

    /*!
     * \brief Show an input dialog
     * \param view The QQuickView to attach the dialog to
     * \param title Optional dialog title
     * \param placeholderText Optional placeholder text for the input field
     * \param initialText Optional initial text in the input field
     * \param callback Function to call when input is submitted or dialog is cancelled
     */
    void showInputDialog(QQuickView *view, const QString &title = QString(),
                         const QString &placeholder_text = QString(),
                         const QString &initial_text = QString(),
                         const InputCallback &callback = nullptr);

    /*!
     * \brief Convenience method for simple text input
     * \param view The QQuickView to attach the dialog to
     * \param title Optional dialog title
     * \param placeholderText Optional placeholder text for the input field
     * \param initialText Optional initial text in the input field
     * \param callback Function to call with the input text (empty string if cancelled)
     */
    void showTextInputDialog(QQuickView *view, const QString &title = QString(),
                             const QString &placeholder_text = QString(),
                             const QString &initial_text = QString(),
                             const std::function<void(const QString &)> &callback = nullptr);

    /*!
     * \brief Check if the dialog is currently visible
     */
    bool isVisible() const;

    /*!
     * \brief Close the dialog programmatically
     */
    void close();

  private slots:
    void onTextSubmitted(const QString &text);
    void onCancelled();

  private:
    QObject *createDialog(QQuickView *view, const QString &title, const QString &placeholder_text,
                          const QString &initial_text);
    void cleanupDialog();
    void invokeCallback(const InputResult &result);

  private:
    QObject *dialog_ = nullptr;
    InputCallback callback_;
};
} // namespace geocontrols
#endif // GEOCONTROLS_QML_INPUT_DIALOG_H
