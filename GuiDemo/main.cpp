

#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtCore/QtContainerFwd>
#include <QtCore/QtEnvironmentVariables>
#include <QtCore/QtLogging>
#include <QtGui/QGuiApplication>
#include <QtGui/QSurfaceFormat>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickWindow>
#include <QtQuick/QSGRendererInterface>

#include "Controls/Vector3SpinBoxWrapper.h"
#include "FontMetricsProvider.h"
#include "ThemeHelper.h"

int main(int argc, char *argv[])
{
#if defined(_WIN32)
    // never use ANGLE on Windows, since OCCT 3D Viewer does not expect this
    QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
#elif defined(__APPLE__)
    qputenv("QT_QPA_PLATFORM", "cocoa");
#else
    // wayland-egl, minimal, xcb, vnc, linuxfb, eglfs, minimalegl, offscreen,
    // wayland, vkkhrdisplay.
    qputenv("QT_QPA_PLATFORM", "xcb");

    // WSL2-specific workarounds
    const char *wslEnv = getenv("WSL_DISTRO_NAME");
    if (wslEnv != nullptr)
    {
        // Force software OpenGL in WSL2 if D3D12 causes issues
        // qputenv("LIBGL_ALWAYS_SOFTWARE", "1");

        // Disable VSync which can cause issues in WSL2
        qputenv("vblank_mode", "0");
        qputenv("__GL_SYNC_TO_VBLANK", "0");

        // Force OpenGL 3.3 compatibility profile for better WSL2 support
        qputenv("MESA_GL_VERSION_OVERRIDE", "3.3COMPAT");
        qputenv("MESA_GLSL_VERSION_OVERRIDE", "330");
    }
#endif

    // Set up OpenGL surface format BEFORE creating QGuiApplication
    QSurfaceFormat aGlFormat;
    aGlFormat.setDepthBufferSize(24);
    aGlFormat.setStencilBufferSize(8);

// Use compatibility profile and fallback version for WSL2
#if defined(_WIN32)
    aGlFormat.setVersion(4, 5);
    aGlFormat.setProfile(QSurfaceFormat::CoreProfile);
#else
    // Use a more compatible version for WSL2/D3D12
    aGlFormat.setVersion(3, 3);
    aGlFormat.setProfile(QSurfaceFormat::CompatibilityProfile);
#endif

    QSurfaceFormat::setDefaultFormat(aGlFormat);

    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    // Set non-native style to support custom controls
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QGuiApplication app(argc, argv);

    // use QQuickView to create window and load QML
    QQuickView view;
    view.setTitle("GeoToy.Controls Demo");
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.resize(1200, 800);

    // Initialize theme helper and font metrics on heap
    auto themeHelper = new networkutil::ThemeHelper(&app);
    auto fontMetrics = new networkutil::FontMetricsProvider(&app);
    fontMetrics->setFont(themeHelper->appFont());

    // Set context properties for global access
    view.rootContext()->setContextProperty("themeHelper", themeHelper);
    view.rootContext()->setContextProperty("fontMetrics", fontMetrics);

    view.setSource(QUrl("qrc:/main.qml"));
    if (view.status() == QQuickView::Error)
    {
        const auto qmlErrors = view.errors();
        for (const auto &err : qmlErrors)
            qWarning().noquote() << err.toString();
        qWarning("Failed to load QML file!");
        return -1;
    }

    // After loading main.qml, set the server configer instances and demonstrate
    // CustomVector3SpinBox usage
    if (view.status() == QQuickView::Ready)
    {
        QQuickItem *rootItem = view.rootObject();
        if (rootItem)
        {
            QQuickItem *positionVector = rootItem->findChild<QQuickItem *>("positionVector");
            // Create Vector3SpinBox wrappers for C++ integration
            auto positionWrapper = new geotoys::Vector3SpinBoxWrapper(&app);
            if (positionVector)
            {
                positionWrapper->setQmlItem(positionVector);

                // Configure the spinbox properties FIRST before setting values
                positionWrapper->setLabel("Position");
                positionWrapper->setDecimals(2);
                positionWrapper->setStepSize(0.5);
                positionWrapper->setFrom(-1000.0);
                positionWrapper->setTo(1000.0);

                // Set initial position after configuration
                positionWrapper->setVector(10.5, 20.3, 30.7);
                qDebug() << "Initial position set to:" << positionWrapper->vectorArray()[0]
                         << positionWrapper->vectorArray()[1] << positionWrapper->vectorArray()[2];

                // Connect to signals for real-time updates
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
    }

    view.show();

    return app.exec();
}
