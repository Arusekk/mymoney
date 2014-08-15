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
TEMPLATE=app
QT += qml quick widgets

TARGET = mymoney

SOURCES += src/mymoney.cpp \
    src/appinfo.cpp \
    src/jsonloader.cpp \
    src/transactionsmanager.cpp \
    src/accounttypemanager.cpp \
    src/themewrapper_pc.cpp

OTHER_FILES += \
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
    qml/pages/TransactionDelegate.qml \
    rpm/harbour-mymoney.yaml \
    translations/harbour-mymoney-sv.ts \
    translations/harbour-mymoney-fi.ts \
    qml/pages/GraphPage.qml \
    qml/pages/DonatePage.qml \
    qml/pages/ComboAccountToFrom.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/CurrencyModel.qml \
    translations/harbour-mymoney-it.ts \
    qml/main_pc.qml \
    qml/pc/ListViewAccounts.qml \
    qml/pc/BackgroundItem.qml \
    qml/pc/BankDelegate.qml

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-mymoney-de.ts
TRANSLATIONS += translations/harbour-mymoney-fi.ts
TRANSLATIONS += translations/harbour-mymoney-sv.ts
TRANSLATIONS += translations/harbour-mymoney-it.ts

DEFINES+= VERSION=\\\"$$VERSION\\\"
DEFINES+=PC
HEADERS += \
    src/gen_config.h \
    src/appinfo.h \
    src/jsonloader.h \
    src/transactionsmanager.h \
    src/accounttypemanager.h \
    src/themewrapper_pc.h

other.files = ChangeLog.txt LICENSE.txt
other.path = /usr/share/harbour-mymoney/
INSTALLS += other

other2.files =  doc/mymoney*.json
other2.path = /usr/share/harbour-mymoney/templates/
INSTALLS += other2

RESOURCES += \
    qrc_pc.qrc
