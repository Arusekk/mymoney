# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-mymoney

CONFIG += sailfishapp

SOURCES += src/mymoney.cpp \
    src/appinfo.cpp \
    src/jsonloader.cpp \
    src/transactionsmanager.cpp

OTHER_FILES += qml/mymoney.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/mymoney.changes.in \
    rpm/harbour-mymoney.spec \
    rpm/harbour-mymoney.yaml \
    translations/*.ts \
    harbour-mymoney.desktop \
    qml/pages/LicensePage.qml \
    qml/pages/CreditsModel.qml \
    qml/pages/ChangeLog.qml \
    qml/pages/AboutPage.qml \
    ChangeLog.txt \
    harbour-mymoney.png \
    qml/pages/BankDelegate.qml \
    qml/pages/AddAccountPage.qml \
    doc/mymoney.json \
    qml/pages/AddTransactionPage.qml \
    qml/pages/TransactionsPage.qml \
    qml/pages/TransactionDelegate.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/mymoney-de.ts

HEADERS += \
    src/gen_config.h \
    src/appinfo.h \
    src/jsonloader.h \
    src/transactionsmanager.h

other.files = ChangeLog.txt LICENSE.txt
other.path = /usr/share/harbour-mymoney/
INSTALLS += other

other2.files =  doc/mymoney.json
other2.path = /usr/share/harbour-mymoney/templates/
INSTALLS += other2

RESOURCES += \
    qrc.qrc
