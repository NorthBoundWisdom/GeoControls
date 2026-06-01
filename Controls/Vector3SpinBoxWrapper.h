#ifndef GEOCONTROLS_VECTOR3SPIN_BOX_WRAPPER_H
#define GEOCONTROLS_VECTOR3SPIN_BOX_WRAPPER_H

#include <array>

#include <QtCore/QVariantList>

class QQuickItem;

namespace geocontrols
{
/**
 * @brief C++ wrapper for CustomVector3SpinBox QML component
 *
 * This class provides a convenient C++ interface for working with
 * the CustomVector3SpinBox QML component, allowing easy vector
 * manipulation and property binding.
 */
class Vector3SpinBoxWrapper : public QObject
{
    Q_OBJECT

    // Properties that can be bound in QML
    Q_PROPERTY(QVariantList vector READ vector WRITE setVector NOTIFY vectorChanged)
    Q_PROPERTY(double x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(double y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(double z READ z WRITE setZ NOTIFY zChanged)
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)
    Q_PROPERTY(double from READ from WRITE setFrom NOTIFY fromChanged)
    Q_PROPERTY(double to READ to WRITE setTo NOTIFY toChanged)
    Q_PROPERTY(double stepSize READ stepSize WRITE setStepSize NOTIFY stepSizeChanged)
    Q_PROPERTY(int decimals READ decimals WRITE setDecimals NOTIFY decimalsChanged)
    Q_PROPERTY(bool editable READ editable WRITE setEditable NOTIFY editableChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

  public:
    explicit Vector3SpinBoxWrapper(QObject *parent = nullptr);

    // Connect to a QML CustomVector3SpinBox item
    void setQmlItem(QQuickItem *qmlItem);
    QQuickItem *qmlItem() const
    {
        return qml_item_;
    }

    // Vector properties
    QVariantList vector() const
    {
        return vector_;
    }
    void setVector(const QVariantList &vector);
    void setVector(const std::array<double, 3> &vector);
    void setVector(double x, double y, double z);
    std::array<double, 3> vectorArray() const;

    // Individual component access
    double x() const
    {
        return vector_[0].toDouble();
    }
    double y() const
    {
        return vector_[1].toDouble();
    }
    double z() const
    {
        return vector_[2].toDouble();
    }

    void setX(double x);
    void setY(double y);
    void setZ(double z);

    // Component access by index
    double component(int index) const;
    void setComponent(int index, double value);

    // SpinBox properties
    QString label() const
    {
        return label_;
    }
    void setLabel(const QString &label);

    double from() const
    {
        return from_;
    }
    void setFrom(double from);

    double to() const
    {
        return to_;
    }
    void setTo(double to);

    double stepSize() const
    {
        return step_size_;
    }
    void setStepSize(double stepSize);

    int decimals() const
    {
        return decimals_;
    }
    void setDecimals(int decimals);

    bool editable() const
    {
        return editable_;
    }
    void setEditable(bool editable);

    bool enabled() const
    {
        return enabled_;
    }
    void setEnabled(bool enabled);

    // Utility methods
    Q_INVOKABLE void reset();
    Q_INVOKABLE double magnitude() const;
    Q_INVOKABLE double magnitudeSquared() const;
    Q_INVOKABLE QVariantList normalized() const;
    Q_INVOKABLE double dotProduct(const QVariantList &other) const;
    Q_INVOKABLE QVariantList crossProduct(const QVariantList &other) const;

  Q_SIGNALS:
    void vectorChanged(const QVariantList &vector);
    void xChanged(double x);
    void yChanged(double y);
    void zChanged(double z);
    void componentChanged(int index, double value);
    void labelChanged(const QString &label);
    void fromChanged(double from);
    void toChanged(double to);
    void stepSizeChanged(double stepSize);
    void decimalsChanged(int decimals);
    void editableChanged(bool editable);
    void enabledChanged(bool enabled);

  private Q_SLOTS:
    void onQmlVectorChanged(const QVariant &newVector);
    void onQmlValueChanged(int index, double newValue);

  private:
    void updateQmlProperty(const QString &propertyName, const QVariant &value);
    void connectQmlSignals();
    void disconnectQmlSignals();

  private:
    QQuickItem *qml_item_ = nullptr;
    QVariantList vector_ = {0.0, 0.0, 0.0};
    QString label_;
    double from_ = -999999.0;
    double to_ = 999999.0;
    double step_size_ = 1.0;
    int decimals_ = 3;
    bool editable_ = true;
    bool enabled_ = true;

    bool updating_ = false; // Prevent recursive updates
};
} // namespace geocontrols
#endif // GEOCONTROLS_VECTOR3SPIN_BOX_WRAPPER_H
