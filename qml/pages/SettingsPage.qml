import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog {
    onAccepted: {
        var  o = modelLanguages.get(comboLocale.currentIndex)
        hideIncome = checkboxHideIncome.checked
        latestMonths = comboMonths.currentIndex+1
        if (o.locale != defaultCurrency) // currency changed?
        {
            defaultCurrency = o.locale
            db.save()
            modelAccounts.reload()
        }
        else
            db.save()
    }

    CurrencyModel { id: modelLanguages; }
    Column {
        anchors.fill: parent
        DialogHeader { title: qsTr("Settings"); }
        ComboBox {
            id: comboLocale
            currentIndex: -1
            label: qsTr("Default currency")
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
                    case "en_GB":
                        currentIndex = 5
                        break;
                    case "zh":
                        currentIndex = 4
                        break;
                    case "sv_SE":
                    case "no_NO":
                    case "da":
                        currentIndex = 3
                        break;
                    case "de_CH":
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
            text: qsTr("Attention! Only accounts with currency '%1' will be shown in graph and cover.").arg(comboLocale.value)
            height: Theme.itemSizeVeryLarge//+Theme.itemSizeSmall
            wrapMode: Text.WordWrap
            width: parent.width-Theme.paddingLarge*2 // wordwrap "hack"
            color: Theme.secondaryHighlightColor
            x: Theme.paddingLarge // wordwrap "hack"
        }
        Separator{ height: 2; anchors.left: parent.left; anchors.right: parent.right; anchors.leftMargin: Theme.paddingMedium; anchors.rightMargin: Theme.paddingMedium; }
        Label {text: qsTr("Account view"); anchors.horizontalCenter: parent.horizontalCenter; }

        TextSwitch{
            id: checkboxHideIncome
            text: qsTr("Hide income")
            checked: hideIncome
        }

        Separator{ height: 2; anchors.left: parent.left; anchors.right: parent.right; anchors.leftMargin: Theme.paddingMedium; anchors.rightMargin: Theme.paddingMedium; }
        Label {text: qsTr("Transaction view"); anchors.horizontalCenter: parent.horizontalCenter; }
        ComboBox {
            id: comboMonths
            label: qsTr("Show latest: ")
            currentIndex: latestMonths-1
            menu: ContextMenu {
                    MenuItem { text: qsTr("month")}
                    MenuItem { text: qsTr("2 months") }
                    MenuItem { text: qsTr("3 months") }
                    MenuItem { text: qsTr("4 months") }
                    MenuItem { text: qsTr("5 months") }
                    MenuItem { text: qsTr("6 months") }
                    MenuItem { text: qsTr("7 months") }
                    MenuItem { text: qsTr("8 months") }
                    MenuItem { text: qsTr("9 months") }
                    MenuItem { text: qsTr("10 months") }
                    MenuItem { text: qsTr("11 months") }
                    MenuItem { text: qsTr("12 months") }
                }
        }
    }

    Component.onCompleted: comboLocale.select(defaultCurrency)
}
