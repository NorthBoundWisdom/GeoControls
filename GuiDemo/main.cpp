#include <QtCore/QAbstractListModel>
#include <QtCore/QCoreApplication>
#include <QtCore/QObject>
#include <QtCore/QStringList>
#include <QtCore/QUrl>
#include <QtCore/QtLogging>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickWindow>

#include "Controls/Vector3SpinBoxWrapper.h"

namespace
{
class DemoCompletionProvider : public QObject
{
    Q_OBJECT

  public:
    explicit DemoCompletionProvider(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QStringList getCompletions(const QString &prefix) const
    {
        const QString normalized_prefix = prefix.trimmed().remove(QChar('/')).toLower();
        const QStringList commands = {"box",  "circle",  "extrude", "fillet",
                                      "help", "measure", "revolve", "select"};
        QStringList completions;
        for (const QString &command : commands)
        {
            if (normalized_prefix.isEmpty() || command.startsWith(normalized_prefix))
            {
                completions.push_back(command);
            }
        }
        return completions;
    }
};

class DemoEndpointConfig : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY endpointConfigChanged)
    Q_PROPERTY(QString port READ port WRITE setPort NOTIFY endpointConfigChanged)
    Q_PROPERTY(QStringList hostList READ hostList NOTIFY endpointConfigChanged)
    Q_PROPERTY(bool hostReachable READ hostReachable NOTIFY endpointConfigChanged)
    Q_PROPERTY(bool portReachable READ portReachable NOTIFY endpointConfigChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY endpointConfigChanged)
    Q_PROPERTY(bool isTesting READ isTesting NOTIFY endpointConfigChanged)

  public:
    explicit DemoEndpointConfig(QObject *parent = nullptr) : QObject(parent) {}

    QString host() const
    {
        return host_;
    }

    void setHost(const QString &host)
    {
        if (host_ == host)
        {
            return;
        }
        host_ = host;
        Q_EMIT endpointConfigChanged();
    }

    QString port() const
    {
        return port_;
    }

    void setPort(const QString &port)
    {
        if (port_ == port)
        {
            return;
        }
        port_ = port;
        Q_EMIT endpointConfigChanged();
    }

    QStringList hostList() const
    {
        return host_list_;
    }

    bool hostReachable() const noexcept
    {
        return host_reachable_;
    }

    bool portReachable() const noexcept
    {
        return port_reachable_;
    }

    bool isConnected() const noexcept
    {
        return is_connected_;
    }

    bool isTesting() const noexcept
    {
        return is_testing_;
    }

    Q_INVOKABLE void addHost(const QString &host)
    {
        const QString trimmed_host = host.trimmed();
        if (trimmed_host.isEmpty() || host_list_.contains(trimmed_host))
        {
            return;
        }
        host_list_.prepend(trimmed_host);
        Q_EMIT endpointConfigChanged();
    }

    Q_INVOKABLE void testConnection()
    {
        is_testing_ = true;
        Q_EMIT endpointConfigChanged();

        host_reachable_ = !host_.trimmed().isEmpty();
        port_reachable_ = !port_.trimmed().isEmpty();
        is_connected_ = host_reachable_ && port_reachable_;
        is_testing_ = false;
        Q_EMIT endpointConfigChanged();
    }

  Q_SIGNALS:
    void endpointConfigChanged();

  private:
    QString host_ = "127.0.0.1";
    QString port_ = "9600";
    QStringList host_list_ = {"127.0.0.1", "192.168.1.12", "10.0.0.5"};
    bool host_reachable_ = true;
    bool port_reachable_ = true;
    bool is_connected_ = true;
    bool is_testing_ = false;
};
} // anonymous namespace

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(icons);

    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QCoreApplication::setApplicationName("GeoControls GuiDemo");
    QGuiApplication::setApplicationDisplayName("GeoControls GuiDemo");
    QGuiApplication app(argc, argv);

    DemoCompletionProvider completion_provider;
    DemoEndpointConfig endpoint_config;

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("completionProvider", &completion_provider);
    engine.rootContext()->setContextProperty("demoEndpointConfig", &endpoint_config);

    engine.load(QUrl("qrc:/main.qml"));
    if (engine.rootObjects().isEmpty())
    {
        qWarning("Failed to load QML file!");
        return -1;
    }

    QObject *root_object = engine.rootObjects().constFirst();
    if (auto *window = qobject_cast<QQuickWindow *>(root_object))
    {
        window->raise();
        window->requestActivate();
    }

    QQuickItem *position_vector = root_object->findChild<QQuickItem *>("positionVector");
    auto position_wrapper = new geocontrols::Vector3SpinBoxWrapper(&app);
    if (position_vector)
    {
        position_wrapper->setQmlItem(position_vector);
        position_wrapper->setLabel("Position");
        position_wrapper->setDecimals(2);
        position_wrapper->setStepSize(0.5);
        position_wrapper->setFrom(-1000.0);
        position_wrapper->setTo(1000.0);
        position_wrapper->setVector(10.5, 20.3, 30.7);
    }

    return app.exec();
}

#include "main.moc"
