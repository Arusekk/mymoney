#include "appinfo.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QStandardPaths>

AppInfo::AppInfo(QObject *)
{
	m_dataPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
	m_longname = QCoreApplication::applicationName();
	m_configPath = QDir{QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)}.filePath(m_longname);
	m_shortname = m_longname.replace("harbour-", "").replace("openrepo-", "");
	m_shortname = m_shortname.replace("_", " ");
	m_shortname = m_shortname.left(1).toUpper() + m_shortname.mid(1);
	QDir dir{m_configPath};
	if (!dir.exists()) dir.mkpath(m_configPath);
	dir.setPath(m_dataPath);
	if (!dir.exists()) dir.mkpath(m_dataPath);
}

QString AppInfo::getLicenseTitle()
{
	return "GPLv2.0";
}

QString AppInfo::getLicenseText()
{
	QString ret = "?";
	QFile file{"/usr/share/harbour-" + m_longname + "/LICENSE.txt"};
	if (file.open(QIODevice::ReadOnly))
		ret = file.readAll();
	return ret;
}

QString AppInfo::getChangeLogText()
{
	QString ret = "?";
	QFile file{"/usr/share/harbour-" + m_longname + "/ChangeLog.txt"};
	if (file.open(QIODevice::ReadOnly))
		ret = file.readAll();
	return ret;
}

