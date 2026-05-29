#include "FontMetricsProvider.h"

#include <QtCore/QObject>

namespace networkutil
{
FontMetricsProvider::FontMetricsProvider(QObject *parent)
    : QObject(parent)
    , m_metrics(QFont())
{
}

void FontMetricsProvider::setFont(const QFont &font)
{
    m_metrics = QFontMetrics(font);
    Q_EMIT fontChanged();
}
} // namespace networkutil
