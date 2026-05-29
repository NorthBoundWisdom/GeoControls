#ifndef GUIDEMO_FONT_METRICS_PROVIDER_H
#define GUIDEMO_FONT_METRICS_PROVIDER_H

#include <QtCore/QObject>
#include <QtGui/QFontMetrics>

namespace networkutil
{
class FontMetricsProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int height READ height NOTIFY fontChanged)
    Q_PROPERTY(int averageCharWidth READ averageCharWidth NOTIFY fontChanged)

  public:
    explicit FontMetricsProvider(QObject *parent = nullptr);

    void setFont(const QFont &font);
    int height() const
    {
        return m_metrics.height();
    }
    int averageCharWidth() const
    {
        return m_metrics.averageCharWidth();
    }

  Q_SIGNALS:
    void fontChanged();

  private:
    QFontMetrics m_metrics;
};
} // namespace networkutil
#endif // GUIDEMO_FONT_METRICS_PROVIDER_H
