import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog {
    onAccepted: {
        var  o = modelLanguages.get(comboLocale.currentIndex)
        hideIncome = checkboxHideIncome.checked
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

        TextSwitch{
            id: checkboxHideIncome
            text: qsTr("Hide income")
            checked: hideIncome
        }

    }

    Component.onCompleted: comboLocale.select(defaultCurrency)
}
