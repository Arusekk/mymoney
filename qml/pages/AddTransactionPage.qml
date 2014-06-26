import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog
{
    id: page
 //   anchors.fill: parent
    property var transaction
    property bool init: true
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

    ListModel {
        id: modelFrom
        function load(group)
        {
            comboFrom.currentIndex = -1
            comboFrom.value = ""
            modelFrom.clear()
            for (var i = 0; i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                if (o.group == group)
                {
                    console.log(o.group+" == "+group+" FROM "+o.title)
                    modelFrom.append({"title" : o.title, "md5" : o.md5})
                }
            }

            comboFrom.menu.update()
           // if (init == false)
             //   comboFrom.clicked(comboFrom)
        }

    }

    ListModel {
        id: modelTo
        function load(group)
        {
            comboTo.currentIndex = -1
            comboTo.value = ""
            modelTo.clear()
            for (var i = 0; i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                if (o.group == group)
                {
                    console.log(o.group+" == "+group+" "+o.title)
                    modelTo.append({"title" : o.title, "md5" : o.md5 })
                }
            }
            //comboTo.menu.contentY = Theme.itemSizeSmall * modelTo.count
        }
    }

    Column{
        anchors.fill: parent
        DialogHeader {  id: header; visible: !entryDescription.focus; title: qsTr("Add transaction"); } //.arg(transaction.md5 == "" ? "Add" : "Change") }
        width: page.width
        Row {
            width: parent.width
            height: Theme.itemSizeSmall
            spacing: 0
            TextSwitch {id: radioOutgoing; text: qsTr("Expense"); width: 205;  onClicked: { radioBank.checked = false; radioIncoming.checked = false; modelFrom.load(modelAccountGroups.get(1).id); modelTo.load(modelAccountGroups.get(2).id); }}
            TextSwitch {id: radioBank; text: qsTr("Bank"); width: 165; onClicked: { radioIncoming.checked = false; radioOutgoing.checked = false; modelFrom.load(modelAccountGroups.get(1).id); modelTo.load(modelAccountGroups.get(1).id); } }
            TextSwitch {id: radioIncoming; text: qsTr("Income"); width: 220; onClicked: { radioBank.checked = false; radioOutgoing.checked = false; modelFrom.load(modelAccountGroups.get(0).id); modelTo.load(modelAccountGroups.get(1).id); } }
        }

        ComboBox{
            id: comboFrom
            label: qsTr("From:")
            currentIndex: -1
            menu: ContextMenu {
                Repeater {
                    width: parent.width
                    //height: 200
                    model: modelFrom
                    delegate: MenuItem { height: Theme.itemSizeSmall; text: title; }
                }
            }

          //  onCurrentIndexChanged: { if (currentIndex != -1) comboTo.clicked(undefined); }
            function getCurrentMd5()
            {
                var o = modelFrom.get(currentIndex)
                return o ? o.md5 : ""
            }
        }

        Label {
            opacity: comboFrom.currentIndex != -1 ? 1.0 : 0.0
            color: isToFromEqual() ? Theme.highlightColor : Theme.primaryColor
            text: isToFromEqual() ? qsTr("To and from must be different") : qsTr("Saldo %1").arg(getAccountSaldoAsString(comboFrom.getCurrentMd5(), entrySum.asDouble() * -1))
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ComboBox{
            id: comboTo
            label: qsTr("To:")
            currentIndex: -1
            onCurrentIndexChanged: { if (currentIndex != -1) entrySum.focus = true; }
            menu:ContextMenu{
                                Repeater {
                                    //height: 200
                                    width: parent.width
                                    model: modelTo;
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
