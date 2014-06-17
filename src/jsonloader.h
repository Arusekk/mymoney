#ifndef JSONLOADER_H
#define JSONLOADER_H

#include <QObject>
#include <QJsonDocument>
#include "appinfo.h"

class JsonLoader : public QObject
{
    Q_OBJECT
    AppInfo *appinfo;
    QJsonDocument json;
public:
    explicit JsonLoader(QObject *parent, AppInfo *appi);

signals:
    void error(QString error);
public slots:
    QString load();
    void save();
    void addAccount(QString name, QString category, QString type, double sum, QString md5);
};

#endif // JSONLOADER_H
