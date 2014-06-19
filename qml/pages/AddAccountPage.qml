import QtQuick 2.0
import Sailfish.Silica 1.0
Dialog {
    id: page
    anchors.fill: parent
    property QtObject account
    property bool block: false
    DialogHeader {  id: header; title: qsTr("%1 account").arg((account && account.md5 != "") ? "Change" : "Add") }

    canAccept: (entrySum.text != "" && entryTitle != "" && comboAccountType.value != "" && comboAccountGroup.value != "")
    onAccepted: {
        var md = account  ? account.md5 : ""
        var group = modelAccountGroups.get(comboAccountGroup.currentIndex).id
        var typ = modelCurrentAccountTypes.get(comboAccountType.currentIndex).title
        modelAccounts.addOrChange(group, entryTitle.text, typ, Number.fromLocaleString(Qt.locale(), entrySum.text), md)
    }

    ListModel {
        id: modelCurrentAccountTypes
        function load(id)
        {
            modelCurrentAccountTypes.clear()
            for (var i = 0; i < modelAccountTypes.count; i++)
            {
                var o = modelAccountTypes.get(i)
                if (o.group == id)
                {
                    modelCurrentAccountTypes.append({"title" : o.type})
                }
            }
        }

        function lookupIndex(id)
        {
            for (var index = 0;index < modelCurrentAccountTypes.count; index++)
            {
                var str = modelCurrentAccountTypes.get(index).title;
                if (str == id)
                    return index;
            }
            return -1;
        }
    }

    Column{
        anchors.top: header.bottom
        anchors.bottom: page.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        TextField {
            id: entryTitle
            focus: true
            text: account ? account.title : ""
            label: qsTr("Name")
            placeholderText: qsTr("Type name here")
            width: parent.width
            Keys.onReturnPressed: focus = text.length > 1
        }

        ComboBox
        {
            id: comboAccountGroup
            label: qsTr("Group")
            currentIndex: -1
            enabled: entrySum.text == "0"
            menu:ContextMenu{
                                Repeater {
                                    model: modelAccountGroups;
                                    MenuItem {
                                        text: title;
                                    }
                                }
                            }
            onCurrentIndexChanged: {
                    modelCurrentAccountTypes.load(modelAccountGroups.get(currentIndex).id);
                }
        }

        ComboBox
        {
            id: comboAccountType
            label: qsTr("Type")
            currentIndex: -1
            menu:ContextMenu{
                                Repeater {
                                    model: modelCurrentAccountTypes;
                                    MenuItem { text: title; }
                                }
                            }
        }

        TextField {
            id: entrySum
            text: account ? account.sum.toLocaleCurrencyString() : "0"
            opacity: (comboAccountGroup.currentIndex != 1 || (account && account.sum != 0)) ? 0.0 : 1.0 // bank only and not edited
            label: qsTr("Starting Balance")
            placeholderText: qsTr("Enter start saldo")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
        }
        Label {
            opacity: (comboAccountGroup.currentIndex != 1 || (account && account.sum != 0)) ? 1.0 : 0.0 // bank only and not edited
            text: qsTr("Saldo %1").arg(account ? account.sum.toLocaleCurrencyString() : Number(0.0).toLocaleCurrencyString())
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Component.onCompleted: {
        comboAccountGroup.currentIndex = account ? modelAccountGroups.lookupIndex(account.group) : -1
        comboAccountType.currentIndex = account ? modelCurrentAccountTypes.lookupIndex(account.type) : -1
    }
}
