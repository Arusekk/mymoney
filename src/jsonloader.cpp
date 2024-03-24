#include "jsonloader.h"

#include <QCryptographicHash>
#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonObject>

#include "appinfo.h"

JsonLoader::JsonLoader(QObject *parent, AppInfo *appinfo)
	: QObject{parent},
	  m_appinfo{appinfo},
	  m_jdoc{},
	  m_transactionmanager{appinfo, this},
	  m_accounttypesmanager{appinfo, this}
{}

QString JsonLoader::dump(void)
{
	return m_jdoc.toJson();
}

void JsonLoader::setupAccountTypes(void)
{
	m_accounttypesmanager.addOrChange("0", tr("Salary"));
	m_accounttypesmanager.addOrChange("0", tr("Student grants"));
	m_accounttypesmanager.addOrChange("0", tr("Unemployment"));
	m_accounttypesmanager.addOrChange("0", tr("Temporary disability"));
	m_accounttypesmanager.addOrChange("0", tr("Loan"));
	m_accounttypesmanager.addOrChange("0", tr("Other income"));
	m_accounttypesmanager.addOrChange("1", tr("Visa"));
	m_accounttypesmanager.addOrChange("1", tr("Maestro"));
	m_accounttypesmanager.addOrChange("1", tr("Mastercard"));
	m_accounttypesmanager.addOrChange("1", tr("Savings"));
	m_accounttypesmanager.addOrChange("1", tr("Other card"));
	m_accounttypesmanager.addOrChange("1", tr("Online money"));
	m_accounttypesmanager.addOrChange("1", tr("Other"));
	m_accounttypesmanager.addOrChange("2", tr("Rent"));
	m_accounttypesmanager.addOrChange("2", tr("Entertainment"));
	m_accounttypesmanager.addOrChange("2", tr("Food"));
	m_accounttypesmanager.addOrChange("2", tr("Travel"));
	m_accounttypesmanager.addOrChange("2", tr("Internet"));
	m_accounttypesmanager.addOrChange("2", tr("Hobby"));
	m_accounttypesmanager.addOrChange("2", tr("Home"));
	m_accounttypesmanager.addOrChange("2", tr("Health"));
	m_accounttypesmanager.addOrChange("2", tr("Insurance"));
	m_accounttypesmanager.addOrChange("2", tr("Media"));
	m_accounttypesmanager.addOrChange("2", tr("Clothes"));
	m_accounttypesmanager.addOrChange("2", tr("Other expence"));
}

QString JsonLoader::getBalanceAccountMd5(void)
{
	return m_jdoc.object()["balanceaccount_md5"].toString();
}

double JsonLoader::getIncomingSaldoForAccount(QString md5)
{
	QString txmd5 = m_transactionmanager.getFirstTransactionForAccount(md5);
	return m_jdoc.object()
		.value("transactions").toObject()[txmd5]
		.toObject()["sum"].toDouble();
}

void JsonLoader::save(void)
{
	QFile file{m_appinfo->m_configPath + "/mymoney.json"};
	qDebug() << "save";

	if (file.open(QIODevice::ReadWrite)) {
		qDebug() << "save";
		file.write(m_jdoc.toJson());
		file.close();
		Q_EMIT error("SAVE");
	} else {
		qDebug() << "savefail";
		Q_EMIT error("Could not save file");
	}
}

QString JsonLoader::addAccount(QString name, QString group, QString type, double sum, QString currency, QString md5)
{
	QJsonObject obj;
	obj["title"] = name;
	obj["group"] = group;
	obj["type"] = type;
	obj["currency"] = currency;
	obj["sum"] = 0.0;

	m_accounttypesmanager.addOrChange(group, type);

	QJsonObject jdoc = m_jdoc.object();

	qDebug() << "=====================";
	qDebug() << m_jdoc.object();
	qDebug() << "=====================";

	QJsonObject accounts = jdoc.value("accounts").toObject();

	if (md5 == "") {
		md5 = QCryptographicHash::hash(
			QDateTime::currentDateTime().toString("hh:mm:ss.zzz dd.MM.yyyy").toUtf8(),
			QCryptographicHash::Md5
		      ).toHex();
		accounts[md5] = obj;
		jdoc.insert("accounts", accounts);
		m_jdoc.setObject(jdoc);
		if (group != "SB")
			m_transactionmanager.add(
				"",
				getBalanceAccountMd5(), md5,
				tr("Balance"), sum, false);
	} else {
		obj["sum"] = accounts[md5].toObject().value("sum").toDouble();
		m_jdoc.setObject(jdoc);
		accounts[md5] = obj;
		jdoc.insert("accounts", accounts);
		m_jdoc.setObject(jdoc);
		m_transactionmanager.add(
			m_transactionmanager.getFirstTransactionForAccount(md5),
			getBalanceAccountMd5(), md5,
			tr("Balance"), sum, false);
	}

	qDebug() << m_jdoc.object();
	save();

	return md5;
}

QString JsonLoader::load(void)
{
	QByteArray buf;
	QFile file{m_appinfo->m_configPath + "/mymoney.json"};
	bool needSetup = false;
	if (!file.open(QIODevice::ReadOnly)) {
		file.setFileName("/usr/share/harbour-mymoney/templates/mymoney.json");
		if (!file.open(QIODevice::ReadOnly))
			Q_EMIT error("Could not load json file");
		else {
			buf += file.readAll();
			file.close();
			needSetup = true;
		}
	} else {
		buf += file.readAll();
		file.close();
	}
	m_jdoc = QJsonDocument::fromJson(buf);
	if (needSetup) {
		QString md5 = addAccount(tr("Balance account"), "SB", tr("Starting balance"), 0.0, m_defaultCurrency, "");
		QJsonObject jdoc = m_jdoc.object();
		QJsonObject accountgroups;
		accountgroups.insert("0", tr("Income"));
		accountgroups.insert("1", tr("Bank"));
		accountgroups.insert("2", tr("Expense"));
		jdoc.insert("accountgroups", accountgroups);
		jdoc.insert("balanceaccount_md5", md5);
		jdoc.insert("version", 2);
		m_jdoc.setObject(jdoc);
		setupAccountTypes();
		save();
	} else {
		QJsonObject jdoc = m_jdoc.object();
		QJsonObject accountgroups;
		QJsonArray accounttypes;
		double version = jdoc.value("version").toDouble();
		if (version == 1.0) {
			jdoc.insert("accountgroups", accountgroups);
			jdoc.insert("version", 2);
			jdoc.insert("accounttypes", accounttypes);
			m_jdoc.setObject(jdoc);
			setupAccountTypes();
		}
		jdoc = m_jdoc.object();
		accountgroups.insert("0", tr("Income"));
		accountgroups.insert("1", tr("Bank"));
		accountgroups.insert("2", tr("Expense"));
		jdoc.insert("accountgroups", accountgroups);
		m_jdoc.setObject(jdoc);
		save();
	}
	m_transactionmanager.getFirstTransactionForAccount("060859ecff9dbf61d0c3d47eee9c5886");
	return m_jdoc.toJson();
}

void JsonLoader::updateAccountSaldo(QString md5, double saldo, bool save)
{
	QJsonObject jdoc = m_jdoc.object();
	QJsonObject accounts = jdoc.value("accounts").toObject();
	QJsonObject account = accounts.value(md5).toObject();
	double oldsum = account["sum"].toDouble();
	account["sum"] = saldo + oldsum;
	if (md5 != getBalanceAccountMd5()) {
		qDebug() << "sum changed for " << md5 << " oldsum " << oldsum
			 << "newsum " << account["sum"] << " +- " << saldo;
	}
	accounts.insert(md5, account);
	jdoc.insert("accounts", accounts);
	m_jdoc.setObject(jdoc);
	if (save) this->save();
}
