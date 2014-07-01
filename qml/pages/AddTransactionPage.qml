import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog
{
    id: page
 //   anchors.fill: parent
    property var transaction
    property bool init: true
    property string to: ""
    property string from: ""
    canAccept: (entryDescription.text != "" && entrySum.text != "" && to != "" && from != "" && entrySum.asDouble() > 0.0 && to != from)
    onAccepted: {
        modelTransactions.add(from, to, entryDescription.text, entrySum.asDouble())
    }

    onFromChanged: console.log("from: "+from)
    function getAccountSaldoAsString(md5, addsum)
    {
        var o = modelAccounts.lookupByMd5(md5)
        return o ?  (o.sum + addsum).toLocaleCurrencyString(Qt.locale(defaultCurrency)) : ""
    }

    ListModel {
        id: modelIncome
        function load(combo)
        {
            combo.model = modelIncome
        }
        function init()
        {
            for (var i = 0; i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                if (o.group == "0")
                {
                    append({"title" : o.title, "md5" : o.md5})
                }
            }
        }

    }

    ListModel {
        id: modelBank
        function load(combo)
        {
            combo.model = modelBank
        }
        function init()
        {
            for (var i = 0; i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                if (o.group == "1")
                {
                    append({"title" : o.title, "md5" : o.md5 })
                }
            }
        }
    }

    ListModel {
        id: modelExpense
        function load(combo)
        {
            combo.model = modelExpense
        }
        function init()
        {
            for (var i = 0; i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                if (o.group == "2")
                {
                    append({"title" : o.title, "md5" : o.md5 })
                }
            }
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
            TextSwitch {id: radioOutgoing; text: qsTr("Expense"); width: 205;  onClicked: { radioBank.checked = false; radioIncoming.checked = false; comboExpense.clear(); }}
            TextSwitch {id: radioBank; text: qsTr("Bank"); width: 165; onClicked: { radioIncoming.checked = false; radioOutgoing.checked = false; comboBank.clear(); } }
            TextSwitch {id: radioIncoming; text: qsTr("Income"); width: 220; onClicked: { radioBank.checked = false; radioOutgoing.checked = false; comboIncome.clear();} }
        }

        ComboAccountToFrom {
            id: comboBank
            visible: radioBank.checked
            modelFrom: modelBank
            modelTo: modelBank
        }

        ComboAccountToFrom {
            id: comboIncome
            visible: radioIncoming.checked
            modelFrom: modelIncome
            modelTo: modelBank
        }

        ComboAccountToFrom {
            id: comboExpense
            visible: radioOutgoing.checked
            modelFrom: modelBank
            modelTo: modelExpense
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
                return text != "" ? Number.fromLocaleString(Qt.locale(defaultCurrency), text) : 0.0
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
        modelIncome.init()
        modelBank.init()
        modelExpense.init()
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
