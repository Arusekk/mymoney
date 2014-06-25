#ifndef ACCOUNTTYPEMANAGER_H
#define ACCOUNTTYPEMANAGER_H
#include <QObject>
#include <QString>
class JsonLoader;
class AccountTypeManager : public QObject
{
    Q_OBJECT
    JsonLoader &loader;
    QJsonDocument &json;
public:
    explicit AccountTypeManager(QObject *parent, JsonLoader &loader);


signals:

public slots:
    void addOrChange(QString group, QString typname);
};

#endif // ACCOUNTTYPEMANAGER_H
