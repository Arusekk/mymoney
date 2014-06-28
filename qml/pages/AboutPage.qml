import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    CreditsModel {id: credits}

    PageHeader {
        title: qsTr("About")
    }

    Timer {
        running: true
        interval: 500
        repeat: false
        onTriggered: pageStack.pushAttached("ChangeLog.qml")
    }
    Column{
        id: column1
        anchors.fill: parent
        anchors.topMargin: Theme.paddingLarge * 4
        spacing: Theme.paddingMedium
        Image{
            source: appinfo.getIcon()
            height: 106
            width: 106
            fillMode: Image.PreserveAspectFit
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
        }
        Label {
            text: appinfo.getName()+" v"+appinfo.getVersion()
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Separator{
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            height: 3
            width: parent.width - (Theme.paddingLarge * 2)
        }

        Label {
            width: 360
            font.pixelSize: Theme.fontSizeMedium
            text: "Copyright 2014 Mike7b4"
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            //wrapMode: Text.WordWrap
            //height: Theme.fontSizeMedium * 1 + 20
        }

        Repeater{
            model: credits
            Item {
                height: url ? button.height : label.height
                width: parent.width
                Label  {
                    id: label
                    visible: model.url === undefined
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: title
                    font.pixelSize: Theme.fontSizeSmall
                }
                Button  {
                    id: button
                    visible: titleurl ? true : false
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: titleurl ? titleurl : ""
                    onClicked: Qt.openUrlExternally(url+"MyMoney v"+appinfo.getVersion())
                }
            }
        }

        Separator{
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            height: 3
            width: parent.width - (Theme.paddingLarge * 2)
        }

        Button {
            text: "License "+appinfo.getLicenseTitle()
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
        }

    }
}
