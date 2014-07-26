#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QVariant>
#include <QDateTime>
#include <QCryptographicHash>
#include <QLocale>
#include "appinfo.h"
#include "jsonloader.h"
#include "transactionsmanager.h"

#define JSON_FILE_VERSION 2
JsonLoader::JsonLoader(QObject *parent, AppInfo *appi) :
    QObject(parent),
    appinfo(appi),
    json(),
    transactions(appi, *this),
    accounttypes(appi, *this),
    defaultCurrency("")
{
}

QString JsonLoader::dump()
{
    return QString(json.toJson());
}

void JsonLoader::addDefaultTypes()
{
    /*
        {"type" : "Loan" , "group" : "0"},
        {"type" : "Salary" , "group" : "0"},
        {"type" : "Student grants" , "group" : "0"},
        {"type" : "Temporary disability" , "group" : "0"},
        {"type" : "Visa" , "group" : "1"},
        {"type" : "Mastercard" , "group" : "1"},
        {"type" : "Maestro" , "group" : "1"},
        {"type" : "Paypal" , "group" : "1"},
        {"type" : "Bitcoin" , "group" : "1"},
        {"type" : "Other Card" , "group" : "1"},
        {"type" : "Other", "group" : "1"},
        {"type" : "Savings" , "group" : "1"},
        {"type" : "Rent" , "group" : "2"},
        {"type" : "Entertainment" , "group" : "2"},
        {"type" : "Car" , "group" : "2"},
        {"type" : "Travel" , "group" : "2"},
        {"type" : "Insurance" , "group" : "2"},
        {"type" : "Internet" , "group" : "2"},
        {"type" : "Food" , "group" : "2"},
        {"type" : "Hobby" , "group" : "2"},
        {"type" : "Other expend" , "group" : "2"}
    */

    accounttypes.addOrChange("0", tr("Salary"));
    accounttypes.addOrChange("0", tr("Student grants"));
    accounttypes.addOrChange("0", tr("Unemployment"));
    accounttypes.addOrChange("0", tr("Temporary disability"));
    accounttypes.addOrChange("0", tr("Loan"));
    accounttypes.addOrChange("0", tr("Other income"));
    accounttypes.addOrChange("1", tr("Visa"));
    accounttypes.addOrChange("1", tr("Maestro"));
    accounttypes.addOrChange("1", tr("Mastercard"));
    accounttypes.addOrChange("1", tr("Savings"));
    accounttypes.addOrChange("1", tr("Other card"));
    accounttypes.addOrChange("1", tr("Online money"));
    accounttypes.addOrChange("1", tr("Other"));
    accounttypes.addOrChange("2", tr("Rent"));
    accounttypes.addOrChange("2", tr("Entertainment"));
    accounttypes.addOrChange("2", tr("Food"));
    accounttypes.addOrChange("2", tr("Travel"));
    accounttypes.addOrChange("2", tr("Internet"));
    accounttypes.addOrChange("2", tr("Hobby"));
    accounttypes.addOrChange("2", tr("Home"));
    accounttypes.addOrChange("2", tr("Health"));
    accounttypes.addOrChange("2", tr("Insurance"));
    accounttypes.addOrChange("2", tr("Media"));
    accounttypes.addOrChange("2", tr("Clothes"));
    accounttypes.addOrChange("2", tr("Other expence"));



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
        QString md5 = addAccount(tr("Balance account"), "SB", tr("Starting balance"), 0.0, defaultCurrency, "");
        QJsonObject obj = json.object();
        QJsonObject groups;
        groups.insert("0", tr("Income"));
        groups.insert("1", tr("Bank"));
        groups.insert("2", tr("Expense"));
        obj.insert("accountgroups", groups);

        obj.insert("balanceaccount_md5", md5);
        obj.insert("version", JSON_FILE_VERSION);
        json.setObject(obj); // and feed it

        addDefaultTypes();
        save();
    }
    else
    {
        QJsonObject obj = json.object();
        QJsonObject groups;
        QJsonArray clr;
        // overwrite json file since we use translations now.
        // FIXME Qt 5.1 has no toInt()
        if (obj.value("version").toDouble() == 1) // if version 1
        {
            obj.insert("accountgroups", groups);
            obj.insert("version", JSON_FILE_VERSION);
            obj.insert("accounttypes", clr); // clear old values with empty array
            json.setObject(obj); // and feed it
            // this makes obj above outdated
            addDefaultTypes();
        }

        // above may have modifiet it reread...
        obj = json.object();
        groups.insert("0", tr("Income"));
        groups.insert("1", tr("Bank"));
        groups.insert("2", tr("Expense"));
        obj.insert("accountgroups", groups);
        json.setObject(obj); // and feed it
        save();
    }

    transactions.getFirstTransactionForAccount("060859ecff9dbf61d0c3d47eee9c5886");

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

QString JsonLoader::addAccount(QString name, QString group, QString type, double sum, QString currency, QString md5)
{
    QJsonObject n;
    n["title"] = name;
    n["group"] = group;
    n["type"] = type;
    n["currency"] = currency;
    n["sum"] = 0.0;

    accounttypes.addOrChange(group, type);
    QJsonObject obj = json.object();
    qDebug() << "=====================";
    qDebug() << json.object();
    qDebug() << "=====================";

    QJsonObject arr = obj.value("accounts").toObject();
    if (md5 == "") // new
    {
        md5 =  QString(QCryptographicHash::hash((QDateTime::currentDateTime().toString("hh:mm:ss.zzz dd.MM.yyyy").toUtf8()),QCryptographicHash::Md5).toHex());
        arr[md5] = n;  // insert new account
        obj.insert("accounts", arr); // update obj
        json.setObject(obj); // and feed it
        if (group != "SB") // are we creating balance account? FIXME remove we should not need this check better add new function and make sure created on initialize
        {
            // nope
            transactions.add("", getBalanceAccountMd5(), md5, tr("Balance"), sum, false);
        }
    }
    else
    {
        n["sum"] = arr[md5].toObject().value("sum").toDouble(); // copy old sum
        arr[md5] = n;  // insert changed account
        obj.insert("accounts", arr); // update obj
        json.setObject(obj); // and feed it
        transactions.add(transactions.getFirstTransactionForAccount(md5), getBalanceAccountMd5(), md5, tr("Balance"), sum, false);
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
    double oldsum = account["sum"].toDouble();
    account["sum"] = oldsum + saldo; // update saldo
    if (md5!=getBalanceAccountMd5())
        qDebug() << "sum changed for " << md5 << " oldsum " << oldsum << "newsum " << account["sum"] << " +- " << saldo;

    accounts.insert(md5, account); // feed back
    obj.insert("accounts", accounts); // update accounts array with changes
    json.setObject(obj); // and feed it

    if (_save)
    {
        save();
    }
}

double JsonLoader::getIncomingSaldoForAccount(QString acmd5)
{
    QString trmd5 = transactions.getFirstTransactionForAccount(acmd5);
    QJsonObject obj = json.object().value("transactions").toObject();
    return obj[trmd5].toObject().value("sum").toDouble();
}
