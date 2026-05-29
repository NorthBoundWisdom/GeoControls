#include "Vector3SpinBoxWrapper.h"

#include <array>
#include <cmath>
#include <cstdlib>

#include <QMetaObject>
#include <QtCore/QDebug>
#include <QtCore/QtContainerFwd>
#include <QtCore/QtNumeric>
#include <QtQuick/QQuickItem>

namespace geotoys
{
namespace
{
constexpr double kComponentEpsilon = 1e-14;
} // namespace

Vector3SpinBoxWrapper::Vector3SpinBoxWrapper(QObject *parent) : QObject(parent) {}

void Vector3SpinBoxWrapper::setQmlItem(QQuickItem *qmlItem)
{
    if (qml_item_ == qmlItem)
        return;

    if (qml_item_)
    {
        disconnectQmlSignals();
    }

    qml_item_ = qmlItem;

    connectQmlSignals();

    // Sync current C++ properties to QML
    updateQmlProperty("vector", vector_);
    updateQmlProperty("label", label_);
    updateQmlProperty("from", from_);
    updateQmlProperty("to", to_);
    updateQmlProperty("stepSize", step_size_);
    updateQmlProperty("decimals", decimals_);
    updateQmlProperty("editable", editable_);
    updateQmlProperty("enabled", enabled_);
}

void Vector3SpinBoxWrapper::setVector(const QVariantList &vector)
{
    if (updating_ || vector_ == vector)
        return;

    updating_ = true;
    vector_ = vector;

    if (qml_item_)
    {
        QMetaObject::invokeMethod(qml_item_, "setVector",
                                  Q_ARG(QVariant, QVariant::fromValue(vector)));
    }

    Q_EMIT vectorChanged(vector_);
    Q_EMIT xChanged(x());
    Q_EMIT yChanged(y());
    Q_EMIT zChanged(z());
    updating_ = false;
}

void Vector3SpinBoxWrapper::setVector(const std::array<double, 3> &vector)
{
    QVariantList list = {vector[0], vector[1], vector[2]};
    setVector(list);
}

void Vector3SpinBoxWrapper::setVector(double x, double y, double z)
{
    QVariantList list = {x, y, z};
    setVector(list);
}

std::array<double, 3> Vector3SpinBoxWrapper::vectorArray() const
{
    return std::array<double, 3>{{x(), y(), z()}};
}

void Vector3SpinBoxWrapper::setX(double x)
{
    setComponent(0, x);
}

void Vector3SpinBoxWrapper::setY(double y)
{
    setComponent(1, y);
}

void Vector3SpinBoxWrapper::setZ(double z)
{
    setComponent(2, z);
}

double Vector3SpinBoxWrapper::component(int index) const
{
    if (index >= 0 && index < vector_.size())
    {
        return vector_[index].toDouble();
    }
    return 0.0;
}

void Vector3SpinBoxWrapper::setComponent(int index, double value)
{
    if (updating_ || index < 0 || index >= 3)
        return;

    updating_ = true;

    // Ensure vector has at least 3 elements
    while (vector_.size() < 3)
    {
        vector_.append(0.0);
    }

    if (std::abs(vector_[index].toDouble() - value) > kComponentEpsilon)
    {
        vector_[index] = value;

        if (qml_item_)
        {
            QMetaObject::invokeMethod(qml_item_, "setComponent", Q_ARG(int, index),
                                      Q_ARG(double, value));
        }

        Q_EMIT vectorChanged(vector_);
        Q_EMIT componentChanged(index, value);

        switch (index)
        {
        case 0:
            Q_EMIT xChanged(value);
            break;
        case 1:
            Q_EMIT yChanged(value);
            break;
        case 2:
            Q_EMIT zChanged(value);
            break;
        }
    }

    updating_ = false;
}

void Vector3SpinBoxWrapper::setLabel(const QString &label)
{
    if (label_ == label)
        return;

    label_ = label;
    updateQmlProperty("label", label_);
    Q_EMIT labelChanged(label_);
}

void Vector3SpinBoxWrapper::setFrom(double from)
{
    if (qFuzzyCompare(from_, from))
        return;

    from_ = from;
    updateQmlProperty("from", from_);
    Q_EMIT fromChanged(from_);
}

void Vector3SpinBoxWrapper::setTo(double to)
{
    if (qFuzzyCompare(to_, to))
        return;

    to_ = to;
    updateQmlProperty("to", to_);
    Q_EMIT toChanged(to_);
}

void Vector3SpinBoxWrapper::setStepSize(double stepSize)
{
    if (qFuzzyCompare(step_size_, stepSize))
        return;

    step_size_ = stepSize;
    updateQmlProperty("stepSize", step_size_);
    Q_EMIT stepSizeChanged(step_size_);
}

void Vector3SpinBoxWrapper::setDecimals(int decimals)
{
    if (decimals_ == decimals)
        return;

    decimals_ = decimals;
    updateQmlProperty("decimals", decimals_);
    Q_EMIT decimalsChanged(decimals_);
}

void Vector3SpinBoxWrapper::setEditable(bool editable)
{
    if (editable_ == editable)
        return;

    editable_ = editable;
    updateQmlProperty("editable", editable_);
    Q_EMIT editableChanged(editable_);
}

void Vector3SpinBoxWrapper::setEnabled(bool enabled)
{
    if (enabled_ == enabled)
        return;

    enabled_ = enabled;
    updateQmlProperty("enabled", enabled_);
    Q_EMIT enabledChanged(enabled_);
}

void Vector3SpinBoxWrapper::reset()
{
    setVector(0.0, 0.0, 0.0);
}

double Vector3SpinBoxWrapper::magnitude() const
{
    return std::sqrt(magnitudeSquared());
}

double Vector3SpinBoxWrapper::magnitudeSquared() const
{
    double dx = x();
    double dy = y();
    double dz = z();
    return (dx * dx) + (dy * dy) + (dz * dz);
}

QVariantList Vector3SpinBoxWrapper::normalized() const
{
    double mag = magnitude();
    if (qFuzzyIsNull(mag))
    {
        return {0.0, 0.0, 0.0};
    }
    return {x() / mag, y() / mag, z() / mag};
}

double Vector3SpinBoxWrapper::dotProduct(const QVariantList &other) const
{
    if (other.size() < 3)
        return 0.0;

    return (x() * other[0].toDouble()) + (y() * other[1].toDouble()) + (z() * other[2].toDouble());
}

QVariantList Vector3SpinBoxWrapper::crossProduct(const QVariantList &other) const
{
    if (other.size() < 3)
        return {0.0, 0.0, 0.0};

    double ox = other[0].toDouble();
    double oy = other[1].toDouble();
    double oz = other[2].toDouble();

    return {(y() * oz) - (z() * oy), (z() * ox) - (x() * oz), (x() * oy) - (y() * ox)};
}

void Vector3SpinBoxWrapper::onQmlVectorChanged(const QVariant &newVector)
{
    if (updating_)
        return;

    QVariantList vectorList = newVector.toList();
    if (vectorList.size() >= 3)
    {
        updating_ = true;
        vector_ = vectorList;
        Q_EMIT vectorChanged(vector_);
        Q_EMIT xChanged(x());
        Q_EMIT yChanged(y());
        Q_EMIT zChanged(z());
        updating_ = false;
    }
}

void Vector3SpinBoxWrapper::onQmlValueChanged(int index, double newValue)
{
    if (updating_ || index < 0 || index >= 3)
        return;

    updating_ = true;

    // Ensure vector has at least 3 elements
    while (vector_.size() < 3)
    {
        vector_.append(0.0);
    }

    vector_[index] = newValue;

    Q_EMIT vectorChanged(vector_);
    Q_EMIT componentChanged(index, newValue);

    switch (index)
    {
    case 0:
        Q_EMIT xChanged(newValue);
        break;
    case 1:
        Q_EMIT yChanged(newValue);
        break;
    case 2:
        Q_EMIT zChanged(newValue);
        break;
    }

    updating_ = false;
}

void Vector3SpinBoxWrapper::updateQmlProperty(const QString &propertyName, const QVariant &value)
{
    if (qml_item_)
    {
        qml_item_->setProperty(propertyName.toUtf8().constData(), value);
    }
}

void Vector3SpinBoxWrapper::connectQmlSignals()
{
    if (!qml_item_)
        return;

    // Connect vector value changed signal
    QObject::connect(qml_item_, SIGNAL(vectorValueChanged(QVariant)), this,
                     SLOT(onQmlVectorChanged(QVariant)));

    // Connect individual value changed signal
    QObject::connect(qml_item_, SIGNAL(valueChanged(int, double)), this,
                     SLOT(onQmlValueChanged(int, double)));
}

void Vector3SpinBoxWrapper::disconnectQmlSignals()
{
    if (qml_item_)
    {
        QObject::disconnect(qml_item_, nullptr, this, nullptr);
    }
}
} // namespace geotoys
