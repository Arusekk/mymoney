#ifndef TRANSACTIONSMANAGER_H
#define TRANSACTIONSMANAGER_H

#include <QObject>

class JsonLoader;
class QJsonDocument;

class TransactionsManager : public QObject {
	Q_OBJECT

Q_SIGNALS:
	void error(QString error);

public Q_SLOTS:
	bool add(QString md5, QString fromaccount, QString toaccount, QString description, double sum, bool save);

public:
	TransactionsManager(QObject *parent, JsonLoader *loader);

	JsonLoader *m_jsonloader;
	QJsonDocument *m_jdoc;
	QString getFirstTransactionForAccount(QString md5);
};

#endif
