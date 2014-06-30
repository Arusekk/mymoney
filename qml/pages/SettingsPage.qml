import QtQuick 2.1
import Sailfish.Silica 1.0
Dialog {
    onAccepted: {
        var  o = modelLanguages.get(comboLocale.currentIndex)
        currentLocale = o.locale
        db.save()
    }

    CurrencyModel { id: modelLanguages; }
    Column {
        anchors.fill: parent
        DialogHeader { title: qsTr("Settings BETA"); }
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

    }

    Component.onCompleted: comboLocale.select(currentLocale)
}
