TEMPLATE = app
TARGET = harbour-mymoney

CONFIG += sailfishapp

HEADERS += \
	src/appinfo.h \
	src/jsonloader.h \
	src/transactionsmanager.h \
	src/accounttypemanager.h \

SOURCES += \
	src/main.cpp \
	src/appinfo.cpp \
	src/jsonloader.cpp \
	src/transactionsmanager.cpp \
	src/accounttypemanager.cpp \

SAILFISHAPP_ICONS = 86x86

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-mymoney.ts \
    translations/harbour-mymoney-de.ts \
    translations/harbour-mymoney-fi.ts \
    translations/harbour-mymoney-it.ts \
    translations/harbour-mymoney-sv.ts \
    translations/harbour-mymoney-zh.ts \

DISTFILES += qml/harbour-mymoney.qml \
    qml/cover/CoverPage.qml \
    qml/pages/*.qml \
    templates/mymoney.json \
    LICENSE.txt \
    ChangeLog.txt \

RESOURCES += mymoney.qrc
