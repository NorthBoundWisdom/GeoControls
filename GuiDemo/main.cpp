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
class DemoCommandConsole : public QObject
{
    Q_OBJECT

  public:
    explicit DemoCommandConsole(QObject *parent = nullptr) : QObject(parent) {}

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

class DemoServerConfiger : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString serverIP READ serverIP WRITE setServerIP NOTIFY serverConfigChangedSig)
    Q_PROPERTY(QString serverPort READ serverPort WRITE setServerPort NOTIFY serverConfigChangedSig)
    Q_PROPERTY(QStringList serverIPList READ serverIPList NOTIFY serverConfigChangedSig)
    Q_PROPERTY(bool serverReachable READ serverReachable NOTIFY serverConfigChangedSig)
    Q_PROPERTY(bool portReachable READ portReachable NOTIFY serverConfigChangedSig)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY serverConfigChangedSig)
    Q_PROPERTY(bool isTesting READ isTesting NOTIFY serverConfigChangedSig)

  public:
    explicit DemoServerConfiger(QObject *parent = nullptr) : QObject(parent) {}

    QString serverIP() const
    {
        return server_ip_;
    }

    void setServerIP(const QString &server_ip)
    {
        if (server_ip_ == server_ip)
        {
            return;
        }
        server_ip_ = server_ip;
        Q_EMIT serverConfigChangedSig();
    }

    QString serverPort() const
    {
        return server_port_;
    }

    void setServerPort(const QString &server_port)
    {
        if (server_port_ == server_port)
        {
            return;
        }
        server_port_ = server_port;
        Q_EMIT serverConfigChangedSig();
    }

    QStringList serverIPList() const
    {
        return server_ip_list_;
    }

    bool serverReachable() const noexcept
    {
        return server_reachable_;
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

    Q_INVOKABLE void addServerIP(const QString &server_ip)
    {
        const QString trimmed_server_ip = server_ip.trimmed();
        if (trimmed_server_ip.isEmpty() || server_ip_list_.contains(trimmed_server_ip))
        {
            return;
        }
        server_ip_list_.prepend(trimmed_server_ip);
        Q_EMIT serverConfigChangedSig();
    }

    Q_INVOKABLE void testConnection()
    {
        is_testing_ = true;
        Q_EMIT serverConfigChangedSig();

        server_reachable_ = !server_ip_.trimmed().isEmpty();
        port_reachable_ = !server_port_.trimmed().isEmpty();
        is_connected_ = server_reachable_ && port_reachable_;
        is_testing_ = false;
        Q_EMIT serverConfigChangedSig();
    }

  Q_SIGNALS:
    void serverConfigChangedSig();

  private:
    QString server_ip_ = "127.0.0.1";
    QString server_port_ = "9600";
    QStringList server_ip_list_ = {"127.0.0.1", "192.168.1.12", "10.0.0.5"};
    bool server_reachable_ = true;
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

    DemoCommandConsole command_console;
    DemoServerConfiger server_configer;

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("commandConsole", &command_console);
    engine.rootContext()->setContextProperty("demoServerConfiger", &server_configer);

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
    auto position_wrapper = new geotoys::Vector3SpinBoxWrapper(&app);
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
