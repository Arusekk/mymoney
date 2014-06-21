import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog
{
    id: page
    anchors.fill: parent
    property QtObject transaction
    property bool block: false
    DialogHeader {  id: header; title: qsTr("%1 Transaction").arg(transaction == null ? "Add" : "Change") }
    canAccept: (entryDescription.text != "" && entrySum.text != "" && comboFrom.value != "" && comboTo.value != "")
    onAccepted: {
        var from = modelFrom.get(comboFrom.currentIndex).md5
        var to = modelTo.get(comboTo.currentIndex).md5
        modelTransactions.add(from, to, entryDescription.text, Number.fromLocaleString(Qt.locale(), entrySum.text))
    }

    Column{
        anchors.top: header.bottom
        anchors.bottom: page.bottom
        anchors.left: parent.left
        anchors.right: parent.right

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
                modelFrom.clear()
                for (var i = 0; i < modelAccounts.count; i++)
                {
                    var o = modelAccounts.get(i)
                    console.log(o.id)
                    if (o.group == group)
                    {
                        modelFrom.append({"title" : o.title, "md5" : o.md5})
                    }
                }
            }
        }

        ListModel {
            id: modelTo
            function load(group)
            {
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
            label: qsTr("From account:")
            currentIndex: -1
            menu:ContextMenu{
                                Repeater {
                                    model: modelFrom;
                                    MenuItem { text: title; }
                                }
                            }
        }

        ComboBox{
            id: comboTo
            label: qsTr("To account:")
            currentIndex: -1
            menu:ContextMenu{
                                Repeater {
                                    model: modelTo;
                                    MenuItem { text: title; }
                                }
                            }
        }

        TextField {
            id: entryDescription
            text: transaction ? transaction.description : ""
            placeholderText: qsTr("Enter Description")
            label: qsTr("Description of transaction")
            width: parent.width
        }

        TextField
        {
            id: entrySum
            text: transaction ? transaction.sum.toLocaleCurrencyString() : ""
            label: qsTr("Amount")
            placeholderText: qsTr("Enter amount")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
        }
    }
}
