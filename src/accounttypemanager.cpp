#include "accounttypemanager.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QDebug>

#include "jsonloader.h"

AccountTypeManager::AccountTypeManager(QObject *parent, JsonLoader *loader)
	: QObject{parent},
	  m_jsonloader{loader},
	  m_jdoc{&loader->m_jdoc}
{
}

void AccountTypeManager::addOrChange(QString group, QString typname)
{
	QJsonObject obj;
	obj["type"] = typname;
	obj["group"] = group;

	QJsonObject jdoc = m_jdoc->object();
	QJsonArray accounttypes = jdoc["accounttypes"].toArray();
	for (int i = 0; i < accounttypes.size(); i++) {
		QJsonObject acctype = accounttypes[i].toObject();
		if (acctype["title"] == typname && acctype["group"] == group)
			return;
	}
	accounttypes.append(obj);
	qDebug() << accounttypes;
	jdoc.insert("accounttypes", accounttypes);
	m_jdoc->setObject(jdoc);
}
