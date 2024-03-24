#include "transactionsmanager.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QDebug>
#include <QJsonObject>

#include "jsonloader.h"

TransactionsManager::TransactionsManager(QObject *parent, JsonLoader *loader)
	: QObject{parent},
	  m_jsonloader{loader},
	  m_jdoc{&loader->m_jdoc}
{
}

bool TransactionsManager::add(QString md5, QString fromaccount, QString toaccount, QString description, double sum, bool save)
{
	QJsonObject obj;
	obj["from"] = fromaccount;
	obj["to"] = toaccount;
	obj["description"] = description;
	obj["sum"] = sum;
	obj["date"] = QDateTime::currentDateTime().toString();

	if (sum == 0.0 && fromaccount == m_jsonloader->getBalanceAccountMd5())
		return false;

	bool modify;
	if (md5 == "") {
		md5 = QCryptographicHash::hash(
			QDateTime::currentDateTimeUtc().toString(Qt::ISODate).toUtf8(),
			QCryptographicHash::Md5
		      ).toHex();
		modify = false;
	} else {
		modify = true;
	}

	QJsonObject jdoc = m_jdoc->object();
	QJsonObject transactions = jdoc["transactions"].toObject();
	if (modify) {
		QJsonObject transaction = transactions[md5].toObject();
		double oldsum = transaction["sum"].toDouble();
		obj["date"] = transaction["date"].toString();
		qDebug() << "oldsum " << oldsum;
		m_jsonloader->updateAccountSaldo(transaction["from"].toString(), oldsum, false);
		m_jsonloader->updateAccountSaldo(transaction["to"].toString(), -oldsum, false);
	}

	transactions[md5] = obj;
	jdoc.insert("transactions", transactions);
	m_jdoc->setObject(jdoc);

	m_jsonloader->updateAccountSaldo(fromaccount, -sum, false);
	m_jsonloader->updateAccountSaldo(toaccount, sum, false);

	qDebug() << obj;
	if (save) m_jsonloader->save();
	return true;
}

QString TransactionsManager::getFirstTransactionForAccount(QString md5)
{
	QJsonObject jdoc = m_jdoc->object();
	QJsonObject transactions = jdoc["transactions"].toObject();
	for (QString key : transactions.keys()) {
		if (   transactions[key].toObject().value("to")   == md5
		    || transactions[key].toObject().value("from") == md5) {
			qDebug() << "firsttransaction lookup " << key
				 << " account " << md5
				 << " sum " << transactions[key].toObject().value("sum").toDouble();
			return key;
		}
	}

	qWarning() << "lookup First Transaction failed for" << md5;
	return "";
}
