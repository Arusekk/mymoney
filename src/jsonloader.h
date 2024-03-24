#ifndef JSONLOADER_H
#define JSONLOADER_H

#include <QJsonDocument>

#include "transactionsmanager.h"
#include "accounttypemanager.h"

class AppInfo;

class JsonLoader : public QObject {
	Q_OBJECT

Q_SIGNALS:
	void error(QString error);

public Q_SLOTS:
	double getIncomingSaldoForAccount(QString md5);
	QString dump(void);
	QString load(void);
	void save(void);
	QString addAccount(QString name, QString group, QString type, double sum, QString currency, QString md5);
	void updateAccountSaldo(QString md5, double saldo, bool save);
	QString getBalanceAccountMd5(void);

public:
	JsonLoader(QObject *parent, AppInfo *appinfo);
	Q_PROPERTY(QString defaultCurrency READ defaultCurrency WRITE setDefaultCurrency)

private:
	AppInfo *m_appinfo;

public:
	QJsonDocument m_jdoc;
	TransactionsManager m_transactionmanager;
	AccountTypeManager m_accounttypesmanager;
	QString m_defaultCurrency;
	void setDefaultCurrency(QString currency) { m_defaultCurrency = currency; }
	QString defaultCurrency(void) const { return m_defaultCurrency; }
	void setupAccountTypes(void);
};

#endif
