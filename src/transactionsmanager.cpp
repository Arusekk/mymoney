#include <QCryptographicHash>
#include <QDateTime>
#include <QDebug>
#include "transactionsmanager.h"
#include "jsonloader.h"

TransactionsManager::TransactionsManager(QObject *parent, JsonLoader &_loader) :
    QObject(parent),
    loader(_loader),
    json(loader.getJson())
{
}

bool TransactionsManager::add(QString fromaccount, QString toaccount, QString description, double sum, bool _save)
{
    QString md5 = QString(QCryptographicHash::hash((QDateTime::currentDateTime().toString(Qt::ISODate).toUtf8()),QCryptographicHash::Md5).toHex());
    QJsonObject n;
    n["from"] = fromaccount;
    n["to"] = toaccount;
    n["description"] = description;
    n["sum"] = sum;
    n["date"] = QDateTime::currentDateTime().toString();

    if (sum == 0.0 && fromaccount != loader.getBalanceAccountMd5()) // only allow 0sum on balance account
    {
        return false;
    }

    QJsonObject obj = json.object();
    QJsonObject arr = obj.value("transactions").toObject();
    arr[md5] = n;  // insert new transaction
    obj.insert("transactions", arr); // update obj
    json.setObject(obj); // and feed it

    loader.updateAccountSaldo(fromaccount, (sum * -1), false);
    loader.updateAccountSaldo(toaccount, sum, false);

    qDebug() << obj;
    qDebug() << json.object();

    if (_save)
    {
        loader.save();
    }

    return true;
}
