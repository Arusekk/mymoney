import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog
{
    id: page
    anchors.fill: parent
    property var transaction
    property bool init: true
    DialogHeader {  id: header; title: qsTr("Add transaction"); } //.arg(transaction.md5 == "" ? "Add" : "Change") }
    canAccept: (entryDescription.text != "" && entrySum.text != "" && comboFrom.value != "" && comboTo.value != "" && entrySum.asDouble() > 0.0 && comboFrom.value != comboTo.value)
    onAccepted: {
        var from = modelFrom.get(comboFrom.currentIndex).md5
        var to = modelTo.get(comboTo.currentIndex).md5
        modelTransactions.add(from, to, entryDescription.text, entrySum.asDouble())
    }

    function getAccountSaldoAsString(md5, addsum)
    {
        var o = modelAccounts.lookupByMd5(md5)
        return o ?  (o.sum + addsum).toLocaleCurrencyString(Qt.locale()) : ""
    }

    function isToFromEqual()
    {
        return comboFrom.getCurrentMd5() == comboTo.getCurrentMd5()
    }

    SilicaFlickable {
        anchors.top: header.bottom
        anchors.bottom: page.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: 800
        Column{
            anchors.fill: parent
            Row {
                width: parent.width
                height: Theme.itemSizeSmall
                spacing: 0
                TextSwitch {id: radioOutgoing; text: qsTr("Expense"); width: 205;  onClicked: { radioBank.checked = false; radioIncoming.checked = false; modelFrom.load(modelAccountGroups.get(1).id); modelTo.load(modelAccountGroups.get(2).id); }}
                TextSwitch {id: radioBank; text: qsTr("Bank"); width: 165; onClicked: { radioIncoming.checked = false; radioOutgoing.checked = false; modelFrom.load(modelAccountGroups.get(1).id); modelTo.load(modelAccountGroups.get(1).id); } }
                TextSwitch {id: radioIncoming; text: qsTr("Income"); width: 220; onClicked: { radioBank.checked = false; radioOutgoing.checked = false; modelFrom.load(modelAccountGroups.get(0).id); modelTo.load(modelAccountGroups.get(1).id); } }
            }

            ListModel {
                id: modelFrom
                function load(group)
                {
                    comboFrom.currentIndex = -1
                    modelFrom.clear()
                    for (var i = 0; i < modelAccounts.count; i++)
                    {
                        var o = modelAccounts.get(i)
                        if (o.group == group)
                        {
                            modelFrom.append({"title" : o.title, "md5" : o.md5})
                        }
                    }

                    if (init == false)
                        comboFrom.clicked(false)
                }

            }

            ListModel {
                id: modelTo
                function load(group)
                {
                    comboTo.currentIndex = -1
                    modelTo.clear()
                    for (var i = 0; i < modelAccounts.count; i++)
                    {
                        var o = modelAccounts.get(i)
                        if (o.group == group)
                        {
                            modelTo.append({"title" : o.title, "md5" : o.md5 })
                        }
                    }
                }
            }

            ComboBox{
                id: comboFrom
                label: qsTr("From:")
                currentIndex: -1
                menu:ContextMenu{
                                    Repeater {
                                        model: modelFrom;
                                        MenuItem { text: title; }
                                    }
                                }

                onCurrentIndexChanged: comboTo.clicked(undefined)
                function getCurrentMd5()
                {
                    var o = modelFrom.get(currentIndex)
                    return o ? o.md5 : ""
                }
            }

            Label {
                visible: comboFrom.currentIndex != -1
                color: isToFromEqual() ? Theme.highlightColor : Theme.primaryColor
                text: isToFromEqual() ? qsTr("To and from must be different") : qsTr("Saldo %1").arg(getAccountSaldoAsString(comboFrom.getCurrentMd5(), entrySum.asDouble() * -1))
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ComboBox{
                id: comboTo
                label: qsTr("To:")
                currentIndex: -1
                onCurrentIndexChanged: entrySum.focus = true
                menu:ContextMenu{
                                    Repeater {
                                        model: modelTo;
                                        MenuItem { text: title; }
                                    }
                                }
                function getCurrentMd5()
                {
                    var o = modelTo.get(currentIndex)
                    return o ? o.md5 : ""
                }
            }

            Label {
                visible: comboTo.currentIndex != -1
                color: isToFromEqual() ? Theme.highlightColor : Theme.primaryColor
                text: isToFromEqual() ? qsTr("To and from must be different") :  qsTr("Saldo %1").arg(getAccountSaldoAsString(comboTo.getCurrentMd5(), entrySum.asDouble()))
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField
            {
                id: entrySum
                text: transaction.sum != 0.0 ? transaction.sum.toLocaleCurrencyString() : ""
                label: qsTr("Amount")
                placeholderText: qsTr("Enter amount")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: DoubleValidator { decimals: 2; }
                width: parent.width
                EnterKey.enabled: asDouble() > 0
                EnterKey.onClicked: { entryDescription.focus = true; }
                function asDouble()
                {
                    return text != "" ? Number.fromLocaleString(Qt.locale(), text) : 0.0
                }
            }

            TextField {
                id: entryDescription
                text: transaction.description
                placeholderText: qsTr("Enter Description")
                label: qsTr("Description of transaction")
                width: parent.width
                EnterKey.enabled: text != "" > 0
                EnterKey.onClicked: { focus = false; }
            }
        }
    }

    Component.onCompleted: {
        switch (transaction.group)
        {
            case "0":
                radioIncoming.clicked(false)
                break;
            case "1":
                radioBank.clicked(false)
                break;
            case "2":
                //radioOutgoing.checked = true
                radioOutgoing.clicked(false)
                break;
        }
        init = false
    }
}
