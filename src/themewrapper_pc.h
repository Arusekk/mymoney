#ifndef THEMEWRAPPER_PC_H
#define THEMEWRAPPER_PC_H

#include <QObject>
#include <QString>
#include <QColor>
#include <QDebug>

class ThemeWrapper_PC : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor primaryColor READ getPrimaryColor NOTIFY ignore)
    Q_PROPERTY(QColor highlightColor READ getPrimaryColor NOTIFY ignore)
    Q_PROPERTY(QColor secondaryColor READ getSecondaryColor NOTIFY ignore)
    Q_PROPERTY(int fontSizeSmall READ getFontSizeSmall NOTIFY ignore)
    Q_PROPERTY(int fontSizeMedium READ getFontSizeMedium NOTIFY ignore)
    Q_PROPERTY(int fontSizeLarge READ getFontSizeLarge NOTIFY ignore)
    Q_PROPERTY(int fontSizeVeryLarge READ getFontSizeVeryLarge NOTIFY ignore)
    Q_PROPERTY(int paddingSmall READ getPaddingSmall NOTIFY ignore)
    Q_PROPERTY(int paddingMedium READ getPaddingMedium NOTIFY ignore)
    Q_PROPERTY(int paddingLarge READ getPaddingLarge NOTIFY ignore)
public:
    explicit ThemeWrapper_PC(QObject *parent = 0);

    int getFontSizeSmall() { return 16; };
    int getFontSizeMedium() { return getFontSizeSmall()*0.25; };
    int getFontSizeLarge() { return getFontSizeMedium()*0.25; };
    int getFontSizeVeryLarge() { return getFontSizeLarge()*0.25; };
    int getPaddingSmall(){return 8;};
    int getPaddingMedium(){return 16;};
    int getPaddingLarge(){return  24;};
    QColor getPrimaryColor() { return QColor("blue"); };
    QColor getSecondaryColor() { return QColor("lightblue"); };
    QColor getHighlightColor() { return QColor("cyan"); };
signals:
    void ignore();
public slots:
};

#endif // THEMEWRAPPER_PC_H
