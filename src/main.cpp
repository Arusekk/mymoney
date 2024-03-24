#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>

#include "jsonloader.h"
#include "appinfo.h"

int main(int argc, char **argv)
{
	QGuiApplication *app = SailfishApp::application(argc, argv);
	app->setQuitOnLastWindowClosed(true);

	AppInfo appinfo{app};
	JsonLoader jsonloader{app, &appinfo};

	QQuickView *view = SailfishApp::createView();

	// QML global objects
	view->rootContext()->setContextProperty("jsonloader", &jsonloader);
	view->rootContext()->setContextProperty("transactionmanager", &jsonloader.m_transactionmanager);
	view->rootContext()->setContextProperty("accounttypesmanager", &jsonloader.m_accounttypesmanager);
	view->rootContext()->setContextProperty("appinfo", &appinfo);

	view->setSource(SailfishApp::pathTo("/qml/mymoney.qml"));
	view->showFullScreen();

	return app->exec();
}
