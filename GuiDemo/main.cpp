
#include <QtCore/QCoreApplication>
#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtCore/QtLogging>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickWindow>

#include "Controls/Vector3SpinBoxWrapper.h"
#include "FontMetricsProvider.h"
#include "ThemeHelper.h"

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(icons);

    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QCoreApplication::setApplicationName("GeoControls GuiDemo");
    QGuiApplication::setApplicationDisplayName("GeoControls GuiDemo");
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");

    auto themeHelper = new networkutil::ThemeHelper(&app);
    auto fontMetrics = new networkutil::FontMetricsProvider(&app);
    fontMetrics->setFont(themeHelper->appFont());

    engine.rootContext()->setContextProperty("themeHelper", themeHelper);
    engine.rootContext()->setContextProperty("fontMetrics", fontMetrics);

    engine.load(QUrl("qrc:/main.qml"));
    if (engine.rootObjects().isEmpty())
    {
        qWarning("Failed to load QML file!");
        return -1;
    }

    QObject *rootObject = engine.rootObjects().constFirst();
    if (rootObject)
    {
        if (auto *window = qobject_cast<QQuickWindow *>(rootObject))
        {
            window->raise();
            window->requestActivate();
        }

        QQuickItem *positionVector = rootObject->findChild<QQuickItem *>("positionVector");
        auto positionWrapper = new geotoys::Vector3SpinBoxWrapper(&app);
        if (positionVector)
        {
            positionWrapper->setQmlItem(positionVector);

            positionWrapper->setLabel("Position");
            positionWrapper->setDecimals(2);
            positionWrapper->setStepSize(0.5);
            positionWrapper->setFrom(-1000.0);
            positionWrapper->setTo(1000.0);

            positionWrapper->setVector(10.5, 20.3, 30.7);
            qDebug() << "Initial position set to:" << positionWrapper->vectorArray()[0]
                     << positionWrapper->vectorArray()[1] << positionWrapper->vectorArray()[2];

            QObject::connect(positionWrapper, &geotoys::Vector3SpinBoxWrapper::vectorChanged,
                             [](const QVariantList &vector)
                             { qDebug() << "Position changed to:" << vector; });

            QObject::connect(positionWrapper, &geotoys::Vector3SpinBoxWrapper::xChanged,
                             [](double x) { qDebug() << "X component changed to:" << x; });
            QObject::connect(positionWrapper, &geotoys::Vector3SpinBoxWrapper::yChanged,
                             [](double y) { qDebug() << "Y component changed to:" << y; });
            QObject::connect(positionWrapper, &geotoys::Vector3SpinBoxWrapper::zChanged,
                             [](double z) { qDebug() << "Z component changed to:" << z; });
        }
    }

    return app.exec();
}
