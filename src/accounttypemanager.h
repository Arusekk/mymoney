#ifndef ACCOUNTTYPEMANAGER_H
#define ACCOUNTTYPEMANAGER_H

#include <QObject>

class JsonLoader;
class QJsonDocument;

class AccountTypeManager : public QObject {
	Q_OBJECT

public Q_SLOTS:
	void addOrChange(QString group, QString typname);

public:
	AccountTypeManager(QObject *parent, JsonLoader *loader);

	JsonLoader *m_jsonloader;
	QJsonDocument *m_jdoc;
};

#endif
