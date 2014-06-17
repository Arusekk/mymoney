#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>
#include "appinfo.h"
#include "jsonloader.h"
JsonLoader::JsonLoader(QObject *parent, AppInfo *appi) :
    QObject(parent),
    appinfo(appi),
    json()
{
}

QString JsonLoader::load()
{
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
        }
        else
            emit error("Could not load json file");
    }

    QJsonParseError err;
    json = QJsonDocument::fromJson(data, &err);
    qDebug() << err.errorString();

    return QString(json.toJson());
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

void JsonLoader::addAccount(QString name, QString category, QString type, double sum, QString md5)
{
    QJsonObject n;
    n["title"] = name;
    n["category"] = category;
    n["banktype"] = type;
    n["sum"] = sum;
    QJsonObject obj = json.object();
    QJsonObject arr = obj.value("accounts").toObject();
    arr[md5] = n;  // insert new account
    obj.insert("accounts", arr); // update obj
    json.setObject(obj); // and feed it

    qDebug() << obj;
    qDebug() << json.object();
    save();
}


