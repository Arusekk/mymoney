#ifndef JSONLOADER_H
#define JSONLOADER_H

#include <QObject>
#include <QJsonDocument>
#include "appinfo.h"
#include "transactionsmanager.h"
#include "accounttypemanager.h"
class JsonLoader : public QObject
{
    Q_OBJECT
    AppInfo *appinfo;
    QJsonDocument json;
    TransactionsManager transactions;
    AccountTypeManager accounttypes;
public:
    explicit JsonLoader(QObject *parent, AppInfo *appi);
    QJsonDocument & getJson(){ return json; };
    TransactionsManager & getTransactionManager() {return transactions;};
    AccountTypeManager & getAccountTypeManager() { return accounttypes; };
    QString getBalanceAccountMd5();
signals:
    void error(QString error);
public slots:
    QString dump();
    QString load();
    void save();
    QString addAccount(QString name, QString group, QString type, double sum, QString md5);
    void updateAccountSaldo(QString md5, double saldo, bool save);
};

#endif // JSONLOADER_H
