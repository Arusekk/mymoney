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
    property string selectedCurrency: defaultCurrency
    onSelectedCurrencyChanged: console.log(selectedCurrency)
    canAccept: (entryDescription.text != "" && entrySum.text != "" && to != "" && from != "" && entrySum.asDouble() > 0.0 && to != from)
    onAccepted: {
        modelTransactions.add(transaction.md5, from, to, entryDescription.text, entrySum.asDouble())
    }

    function getAccountSaldoAsString(md5, addsum)
    {
        var balance = 0.0
        var o = modelAccounts.lookupByMd5(md5)
        if (addsum && (md5 == transaction.from || md5 == transaction.to)) // only balance if change... and not sum == 0.0
        {
            if (addsum > 0) // to
                balance = transaction.sum * -1.0
            else
                balance = transaction.sum
        }
        return o ?  (o.sum + addsum + balance).toLocaleCurrencyString(Qt.locale(o.currency)) : ""
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
        DialogHeader {  id: header; visible: !entryDescription.focus; title: transaction.md5 =="" ? qsTr("Add transaction") : qsTr("Change transaction"); }
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
            objectName: "Bank"
            visible: radioBank.checked
            modelFrom: modelBank
            modelTo: modelBank
        }

        ComboAccountToFrom {
            id: comboIncome
            objectName: "Income"
            visible: radioIncoming.checked
            modelFrom: modelIncome
            modelTo: modelBank
        }

        ComboAccountToFrom {
            id: comboExpense
            objectName: "Expense"
            visible: radioOutgoing.checked
            modelFrom: modelBank
            modelTo: modelExpense
        }

        TextField
        {
            id: entrySum
            text: transaction.sum != 0.0 ? transaction.sum.toLocaleCurrencyString(Qt.locale(selectedCurrency)) : ""
            label: qsTr("Amount")
            placeholderText: qsTr("Enter amount")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
            EnterKey.enabled: asDouble() > 0
            EnterKey.onClicked: { entryDescription.focus = true; }
            function asDouble()
            {
                return text != "" ? Number.fromLocaleString(Qt.locale(selectedCurrency), text) : 0.0
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
                comboIncome.setFromIndexFromMd5(transaction.from)
                comboBank.setToIndexFromMd5(transaction.to)
                break;
            case "1":
                radioBank.checked = true; //clicked(radioBank)
                comboBank.setFromIndexFromMd5(transaction.from)
                comboBank.setToIndexFromMd5(transaction.to)
                break;
            case "2":
                //radioOutgoing.checked = true
                radioOutgoing.checked = true; // clicked(radioOutgoing)
                comboBank.setFromIndexFromMd5(transaction.from)
                comboExpense.setToIndexFromMd5(transaction.to)
                break;
        }

    }
}
