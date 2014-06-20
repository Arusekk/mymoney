#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QCryptographicHash>
#include "appinfo.h"
#include "jsonloader.h"
#include "transactionsmanager.h"
JsonLoader::JsonLoader(QObject *parent, AppInfo *appi) :
    QObject(parent),
    appinfo(appi),
    json(),
    transactions(appi, *this)
{
}

QString JsonLoader::load()
{
    bool fromtemplate = false;
    QByteArray data;
    QFile file(appinfo->getConfigPath()+"/mymoney.json");
    if (file.open(QFile::ReadOnly))
    {
        data.append(file.readAll());
        file.close();
    }
    else
    {
        file.setFileName("/usr/share/harbour-mymoney/templates/mymoney.json");
        if (file.open(QFile::ReadOnly))
        {
            data.append(file.readAll());
            file.close();
            fromtemplate = true; // first time creation
        }
        else
            emit error("Could not load json file");
    }

    QJsonParseError err;
    json = QJsonDocument::fromJson(data, &err);
    if (fromtemplate) // first time creation
    {
        QString md5 = addAccount("Starting balance", "SB", "Starting balance", 0.0, "");
        QJsonObject obj = json.object();
        obj.insert("balanceaccount_md5", md5);
        obj.insert("version", 1);
        json.setObject(obj); // and feed it
        save();
    }

    return QString(json.toJson());
}

QString JsonLoader::getBalanceAccountMd5()
{
    QJsonObject obj = json.object();
    return obj["balanceaccount_md5"].toString();
}

void JsonLoader::save()
{
    QFile file(appinfo->getConfigPath()+"/mymoney.json");
    qDebug() << "save";
    if (file.open(QFile::ReadWrite))
    {
        qDebug() << "save";
        file.write(json.toJson());
        file.close();
        emit error("SAVE");
    }
    else
    {
        qDebug() << "savefail";
        emit error("Could not save file");
    }
}

QString JsonLoader::addAccount(QString name, QString group, QString type, double sum, QString md5)
{
    QJsonObject n;
    n["title"] = name;
    n["group"] = group;
    n["type"] = type;
    n["sum"] = 0.0;
    QJsonObject obj = json.object();
    QJsonObject arr = obj.value("accounts").toObject();
    if (md5 == "") // new
    {
        md5 =  QString(QCryptographicHash::hash((QDateTime::currentDateTime().toString("hh:mm:ss.zzz dd.MM.yyyy").toUtf8()),QCryptographicHash::Md5).toHex());
        arr[md5] = n;  // insert new account
        obj.insert("accounts", arr); // update obj
        json.setObject(obj); // and feed it
        if (group != "SB") // are we creating balance account?
        {
            // nope
            transactions.add(getBalanceAccountMd5(), md5, "Income", sum, false);
        }
    }
    else
    {
        n["sum"] = sum; // copy old sum
        arr[md5] = n;  // insert changed account
        obj.insert("accounts", arr); // update obj
        json.setObject(obj); // and feed it
    }

    qDebug() << json.object();
    save();

    return md5;
}

void JsonLoader::updateAccountSaldo(QString md5, double saldo, bool _save)
{
    QJsonObject obj = json.object();
    QJsonObject accounts = obj.value("accounts").toObject(); // get copy of all accounts
    QJsonObject account = accounts.value(md5).toObject(); // get copy of requested obj
    account["sum"] = account["sum"].toDouble() + saldo; // update saldo
    accounts.insert(md5, account); // feed back
    obj.insert("accounts", accounts); // update accounts array with changes
    json.setObject(obj); // and feed it

    if (_save)
    {
        save();
    }
}
