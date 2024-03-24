#ifndef APPINFO_H
#define APPINFO_H

#include <QObject>

class AppInfo : public QObject {
	Q_OBJECT
public:
	AppInfo(QObject *);
public slots:
	QString getDataPath(void) { return m_dataPath; }
	QString getConfigPath(void) { return m_configPath; }
	QString getInstallPath(void) { return m_installPath; }
	QString getName(void) { return m_shortname; }
	QString getIcon(void) { return "qrc:/" + m_longname + ".png"; }
	QString getVersion(void) { return "0.1.3"; }
	QString getLicenseTitle(void);
	QString getLicenseText(void);
	QString getChangeLogText(void);
public:
	QString m_configPath;
	QString m_dataPath;
	QString m_installPath;
	QString m_shortname;
	QString m_longname;
};

#endif
