#ifndef TRANSACTIONSMANAGER_H
#define TRANSACTIONSMANAGER_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
class JsonLoader;
class TransactionsManager : public QObject
{
    Q_OBJECT
    JsonLoader &loader;
    QJsonDocument &json;
public:
    explicit TransactionsManager(QObject *parent, JsonLoader &loader);
    QString getFirstTransactionForAccount(QString acmd5);
signals:
    void error(QString error);
public slots:
    bool add(QString md5, QString fromaccount, QString toaccount, QString description, double sum, bool save);
};

#endif // TRANSACTIONSMANAGER_H
