import QtQuick 2.1
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

        function lookupIndex(title)
        {
            for (var index = 0;index < modelCurrentAccountTypes.count; index++)
            {
                var str = modelCurrentAccountTypes.get(index).title;
                if (str == title)
                    return index;
            }
            return -1;
        }

        function add(n)
        {
            var index = lookupIndex(n.title)
            if (index != -1)
                return index

            modelCurrentAccountTypes.append(n)
            return modelCurrentAccountTypes.count-1
        }
    }

    Column{
        anchors.top: header.bottom
        anchors.bottom: page.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        ComboBox
        {
            id: comboAccountGroup
            label: qsTr("Group")
            currentIndex: -1
            enabled: entrySum.text == "0"
            focus: true
            menu:ContextMenu{
                                Repeater {
                                    model: modelAccountGroups;
                                    MenuItem {
                                        text: title;
                                    }
                                }
                            }
            onCurrentIndexChanged: {
                    comboAccountType.currentIndex = -1
                    modelCurrentAccountTypes.load(modelAccountGroups.get(currentIndex).id);
                    entryTitle.focus = true
                }
        }

        TextField {
            id: entryTitle
            text: account ? account.title : ""
            label: qsTr("Name")
            placeholderText: qsTr("Type name here")
            width: parent.width
            Keys.onReturnPressed: typeEntry.focus = text.length > 0
        }

        TextField {
            id: typeEntry
            visible: comboAccountType.currentIndex == -1
            enabled: comboAccountGroup.currentIndex != -1
            placeholderText: qsTr("Enter new type or select from below")
            width: parent.width
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            // onclicked only if empty text we show menu
            onPressAndHold: { if (typeEntry.text.length == 0)
                                { focus = false;  comboAccountType.clicked(undefined); }
                        }
            Keys.onReturnPressed: {
                if (typeEntry.text.length)
                {
                    var ind = modelCurrentAccountTypes.add({"title" : typeEntry.text, "group" : modelAccountGroups.get(comboAccountGroup.currentIndex).id});
                    comboAccountType.currentIndex = ind
                    typeEntry.text = ""
                    typeEntry.focus = false
                    comboAccountType.menu.show(comboAccountType)
                    comboAccountType.menu.hide()
                }
                else
                {
                    focus = false;
                    comboAccountType.clicked(comboAccountType)
                }
            }
        }
        ComboBox
        {
            id: comboAccountType
            visible: comboAccountGroup.currentIndex != -1
            label: qsTr("Type")
            currentIndex: -1
           //height: menu.active ? 600 : Theme.itemSizeMedium
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
            visible: (comboAccountGroup.currentIndex != 1 || account) ? false : true // bank only and not edited
            label: qsTr("Starting Balance")
            placeholderText: qsTr("Enter start saldo")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
        }
        Label {
            opacity: (comboAccountGroup.currentIndex != 1 || (account && account.sum != 0)) ? 1.0 : 0.0 // bank only and not edited
            text: qsTr("Saldo %1").arg(getSaldo())
            anchors.horizontalCenter: parent.horizontalCenter
            function getSaldo()
            {
                if (account)
                    return account.group == "0" ? (account.sum * -1).toLocaleCurrencyString(Qt.locale()) : account.sum.toLocaleCurrencyString(Qt.locale())

                return Number(0.0).toLocaleCurrencyString(Qt.locale())
            }
        }
    }

    Component.onCompleted: {
        comboAccountGroup.currentIndex = account ? modelAccountGroups.lookupIndex(account.group) : -1
        comboAccountType.currentIndex = account ? modelCurrentAccountTypes.lookupIndex(account.type) : -1
    }

    Timer{
        interval: 200
        running: true
        onTriggered:{
            console.log("boom");
                            if (comboAccountGroup.currentIndex == -1)
                                 comboAccountGroup.menu.show(comboAccountGroup)
                    }
    }
}
