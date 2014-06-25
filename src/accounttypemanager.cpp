#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include "accounttypemanager.h"
#include "jsonloader.h"

AccountTypeManager::AccountTypeManager(QObject *parent, JsonLoader &json) :
    QObject(parent),
    loader(json),
    json(loader.getJson())
{
}

void AccountTypeManager::addOrChange(QString group, QString typname)
{
    QJsonObject n;
    n["type"] = typname;
    n["group"] = group;
    QJsonObject obj = json.object();
    QJsonArray arr = obj.value("accounttypes").toArray();
    foreach(const QJsonValue &v, arr)
    {
        QJsonObject o = v.toObject();
        if (o["title"] == typname && o["group"] == group)
            return ;
    }
    arr.append(n);
    qDebug() << arr;
    obj.insert("accounttypes", arr); // update obj
    json.setObject(obj); // and feed it
}
