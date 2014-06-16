import QtQuick 2.1
import Sailfish.Silica 1.0
Page
{
    anchors.fill: parent
    PageHeader {
        title: qsTr("ChangeLog")
    }

    TextArea
    {
        anchors.fill: parent
        anchors.topMargin: Theme.paddingLarge * 4
        text: appinfo.getChangeLogText();
        readOnly: true
    }
}

