#include <QCryptographicHash>
#include <QDateTime>
#include <QJsonArray>
#include <QStringList>
#include <QDebug>
#include "transactionsmanager.h"
#include "jsonloader.h"

TransactionsManager::TransactionsManager(QObject *parent, JsonLoader &_loader) :
    QObject(parent),
    loader(_loader),
    json(loader.getJson())
{
}

bool TransactionsManager::add(QString trmd5, QString fromaccount, QString toaccount, QString description, double sum, bool _save)
{
    bool updatetransaction = true;
    double oldsum = 0.0;
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

    if (trmd5 == "")
    {
        updatetransaction = false;
        trmd5 = QString(QCryptographicHash::hash((QDateTime::currentDateTimeUtc().toString(Qt::ISODate).toUtf8()),QCryptographicHash::Md5).toHex());
    }

    QJsonObject obj = json.object();
    QJsonObject arr = obj.value("transactions").toObject();
    if (updatetransaction)
    {
        QJsonObject oldtr = arr[trmd5].toObject();
        oldsum = oldtr["sum"].toDouble();
        n["date"] = oldtr["date"].toString(); // keep old date
        qDebug() << "oldsum " << oldsum;
        loader.updateAccountSaldo(oldtr["from"].toString(), oldsum, false);
        loader.updateAccountSaldo(oldtr["to"].toString(), oldsum * -1, false);
        // loader has changed json..
        obj = json.object();
    }

    arr = obj.value("transactions").toObject();
    arr[trmd5] = n;  // insert new transaction
    obj.insert("transactions", arr); // update obj
    json.setObject(obj); // and feed it

    loader.updateAccountSaldo(fromaccount, (sum * -1), false);
    loader.updateAccountSaldo(toaccount, sum, false);

    qDebug() << json.object();

    if (_save)
    {
        loader.save();
    }

    return true;
}

QString TransactionsManager::getFirstTransactionForAccount(QString acmd5)
{
    QString balancemd5 = loader.getBalanceAccountMd5();
    QJsonObject obj = json.object().value("transactions").toObject();
    foreach(const QString &key, obj.keys())
    {
        if (obj[key].toObject().value("to").toString() == acmd5 &&
            obj[key].toObject().value("from").toString() == balancemd5)
        {
            qDebug() << "firsttransaction lookup " << key << " account " << acmd5 << " sum " << obj[key].toObject().value("sum").toDouble();
            return key;
        }
    }

    qWarning() << "lookup First Transaction failed for" << acmd5;
    return "";
}

