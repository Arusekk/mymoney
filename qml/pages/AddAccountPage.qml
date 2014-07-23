import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog {
    id: page
    anchors.fill: parent
    property QtObject account
    property bool block: false
    property string selectedCurrency: comboLocale.currentIndex != -1 ? modelLanguages.get(comboLocale.currentIndex).locale : "en"
    onSelectedCurrencyChanged: console.log(selectedCurrency)
    DialogHeader {  id: header; title: qsTr("Account"); }

    canAccept: (entrySum.text != "" && entryTitle.text != "" && comboAccountType.value != "" && comboAccountGroup.value != "" && comboLocale.value != "")
    onAccepted: {
        var reload = false
        var md = account  ? account.md5 : ""
        var group = modelAccountGroups.get(comboAccountGroup.currentIndex).id
        var typ = modelCurrentAccountTypes.get(comboAccountType.currentIndex).title
        var currency = modelLanguages.get(comboLocale.currentIndex).locale
        console.log("md"+md)
        modelAccounts.addOrChange(group, entryTitle.text, typ, Number.fromLocaleString(Qt.locale(), entrySum.text), currency, md)
    }

    CurrencyModel { id: modelLanguages; }

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
            placeholderText: qsTr("Enter new type or press enter key")
            width: parent.width
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
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
            menu:ContextMenu{
                                Repeater {
                                    model: modelCurrentAccountTypes;
                                    MenuItem { text: title; }
                                }
                            }
        }

        ComboBox {
            id: comboLocale
            currentIndex: -1
            label: qsTr("Currency")
            menu: ContextMenu {
                Repeater {
                    model: modelLanguages
                    MenuItem {text: model.title;}
                }
            }
            function select(local)
            {
                local = local.split(".")[0]
                switch(local)
                {
                    case "sv_SE":
                    case "no_NO":
                    case "da":
                        currentIndex = 3
                        break;
                    case "de-ch":
                        currentIndex = 2
                        break
                    case "en_US":
                        currentIndex = 1
                        break
                    default:
                        currentIndex = 0
                        break
                }
            }
        }

        Label {
            visible: defaultCurrency != modelLanguages.get(comboLocale.currentIndex).locale
            text: qsTr("Attention! If you set up an account to currencies other than the default currency in settings, then this account does not appear in the chart or cover.")
            height: Theme.itemSizeVeryLarge//+Theme.itemSizeSmall
            wrapMode: Text.WordWrap
            width: parent.width-Theme.paddingLarge*2 // wordwrap "hack"
            color: Theme.secondaryHighlightColor
            x: Theme.paddingLarge // wordwrap "hack"
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
                    return account.group == "0" ? (account.sum * -1).toLocaleCurrencyString(Qt.locale(selectedCurrency)) : account.sum.toLocaleCurrencyString(Qt.locale(selectedCurrency))

                return Number(0.0).toLocaleCurrencyString(Qt.locale(selectedCurrency))
            }
        }
    }

    Component.onCompleted: {
        comboAccountGroup.currentIndex = account ? modelAccountGroups.lookupIndex(account.group) : -1
        comboAccountType.currentIndex = account ? modelCurrentAccountTypes.lookupIndex(account.type) : -1
        comboLocale.currentIndex = account ? comboLocale.select(account.currency) : comboLocale.select(defaultCurrency)
    }

    Timer{
        interval: 200
        running: true
        onTriggered:{
                        if (comboAccountGroup.currentIndex == -1)
                            comboAccountGroup.menu.show(comboAccountGroup)
                    }
    }
}
