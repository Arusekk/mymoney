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
    QString defaultCurrency;
    void addDefaultTypes();
    QString getDefaultCurrency(){ return defaultCurrency; };
    void setDefaultCurrency(QString currency){ defaultCurrency = currency; };
public:
    explicit JsonLoader(QObject *parent, AppInfo *appi);
    Q_PROPERTY(QString defaultCurrency READ getDefaultCurrency WRITE setDefaultCurrency)
    QJsonDocument & getJson(){ return json; };
    TransactionsManager & getTransactionManager() {return transactions;};
    AccountTypeManager & getAccountTypeManager() { return accounttypes; };
signals:
    void error(QString error);
public slots:
    QString dump();
    QString load();
    void save();
    QString addAccount(QString name, QString group, QString type, double sum, QString currency, QString md5);
    void updateAccountSaldo(QString md5, double saldo, bool save);
    QString getBalanceAccountMd5();
};

#endif // JSONLOADER_H
