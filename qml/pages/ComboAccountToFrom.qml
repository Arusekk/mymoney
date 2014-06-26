import QtQuick 2.0
import Sailfish.Silica 1.0
Column {
    property var modelTo
    property var modelFrom
    width: parent.width
    height: childrenRect.height
    function clear()
    {
        comboFrom.currentIndex = -1;
        comboTo.currentIndex = -1;
        to = ""
        from = ""
    }

    function isToFromEqual()
    {
        return comboFrom.getCurrentMd5() == comboTo.getCurrentMd5()
    }

    ComboBox{
        id: comboFrom
        label: qsTr("From:")
        currentIndex: -1
        onCurrentIndexChanged: { if (currentIndex != -1) entrySum.focus = true; from = getCurrentMd5();}
        menu:ContextMenu{
                            Repeater {
                                //height: 200
                                width: parent.width
                                model: modelFrom
                                delegate: MenuItem {  height: Theme.itemSizeSmall; text: title; }
                            }
                        }

        function getCurrentMd5()
        {
            var o = modelFrom.get(currentIndex)
            return o ? o.md5 : ""
        }
    }

    Label {
        opacity: comboFrom.currentIndex != -1 ? 1.0 : 0.0
        color: isToFromEqual() ? Theme.highlightColor : Theme.primaryColor
        text: isToFromEqual() ? qsTr("To and from must be different") :  qsTr("Saldo %1").arg(getAccountSaldoAsString(comboFrom.getCurrentMd5(), entrySum.asDouble() * -1))
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ComboBox{
        id: comboTo
        label: qsTr("To:")
        currentIndex: -1
        onCurrentIndexChanged: { if (currentIndex != -1) entrySum.focus = true; to = getCurrentMd5(); }
        menu:ContextMenu{
                            Repeater {
                                //height: 200
                                width: parent.width
                                model: modelTo
                                delegate: MenuItem {  height: Theme.itemSizeSmall; text: title; }
                            }
                        }
        function getCurrentMd5()
        {
            var o = modelTo.get(currentIndex)
            return o ? o.md5 : ""
        }
    }

    Label {
        opacity: comboTo.currentIndex != -1 ? 1.0 : 0.0
        color: isToFromEqual() ? Theme.highlightColor : Theme.primaryColor
        text: isToFromEqual() ? qsTr("To and from must be different") :  qsTr("Saldo %1").arg(getAccountSaldoAsString(comboTo.getCurrentMd5(), entrySum.asDouble()))
        anchors.horizontalCenter: parent.horizontalCenter
    }


}
