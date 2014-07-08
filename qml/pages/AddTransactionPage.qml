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

    function getAccountSaldoAsString(md5, addsum)
    {
        var o = modelAccounts.lookupByMd5(md5)
        return o ?  (o.sum + addsum).toLocaleCurrencyString(Qt.locale(o.currency)) : ""
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
        Grid {
            width: parent.width
            visible: !(entryDescription.focus || entrySum.focus)
            rows: 2
            columns: 2
            spacing: 0
            TextSwitch {id: radioOutgoing; text: qsTr("Expense"); width: parent.width/2;  onClicked: { radioBank.checked = false; radioIncoming.checked = false; comboExpense.clear(); }}
            TextSwitch {id: radioBank; text: qsTr("Bank"); width: parent.width/2; onClicked: { radioIncoming.checked = false; radioOutgoing.checked = false; comboBank.clear(); } }
            TextSwitch {id: radioIncoming; text: qsTr("Income"); width: parent.width/2; onClicked: { radioBank.checked = false; radioOutgoing.checked = false; comboIncome.clear();} }
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

    onStatusChanged: if (status == PageStatus.Active && init) setup();

    function setup()
    {
        modelIncome.init()
        modelBank.init()
        modelExpense.init()
        hackt.start()
        init = false
    }

    Timer {
        id: hackt
        running: false
        interval: 1
        onTriggered: hack()
    }

    function hack()
    {
        switch (transaction.group)
        {
            case "0":
                radioIncoming.checked=true;//clicked(radioIncoming)
                if (transaction)
                    comboIncome.setFromIndexFromMd5(transaction.from)
                break;
            case "1":
                radioBank.checked = true; //clicked(radioBank)
                if (transaction)
                    comboBank.setFromIndexFromMd5(transaction.from)
                break;
            case "2":
                //radioOutgoing.checked = true
                radioOutgoing.checked = true; // clicked(radioOutgoing)
                if (transaction && transaction.to)
                    comboExpense.setToIndexFromMd5(transaction.to)
                break;
        }

    }
}
