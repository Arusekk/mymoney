import QtQuick 2.0
import Sailfish.Silica 1.0
Dialog {
    id: page
    anchors.fill: parent
    DialogHeader {  id: header; title: qsTr("%1 account").arg(_md5 == "" ? "Add" : "Change") }
    property string _md5: ""

    canAccept: (entrySum.text != "" && entryTitle != "")
    onAccepted: {
        var cat = modelCategorys.get(comboCategory.currentIndex).category
        var typ = modelCurrentTypes.get(comboType.currentIndex).title
        modelBanks.addOrChange(cat, entryTitle.text, typ, Number.fromLocaleString(Qt.locale(), entrySum.text), _md5)
    }

    ListModel {
        id: modelCurrentTypes
        function load(allowed)
        {
            allowed = allowed.substr(1, allowed.length)
            modelCurrentTypes.clear()
            for (var i = 0; i < modelTypes.count; i++)
            {
                console.log("== "+modelTypes.get(i).category+" "+i)
                if (modelTypes.get(i).category == allowed)
                {
                    modelCurrentTypes.append({"title" : modelTypes.get(i).banktype})
                }
            }
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
            text: ""
            label: qsTr("Name")
            placeholderText: qsTr("Type name here")
            width: parent.width
            Keys.onReturnPressed: focus = text.length > 1
        }

        ComboBox
        {
            id: comboCategory
            label: qsTr("Category")
            currentIndex: -1
            menu:ContextMenu{
                                Repeater {
                                    model: modelCategorys;
                                    MenuItem { text: category.substr(1, category.length);}
                                }
                            }
            onCurrentIndexChanged: { modelCurrentTypes.load(modelCategorys.get(currentIndex).category); comboType._menuOpen(); }
        }

        ComboBox
        {
            id: comboType
            label: qsTr("Type")
            menu:ContextMenu{
                                Repeater {
                                    model: modelCurrentTypes;
                                    MenuItem { text: title; }
                                }
                            }
        }

        TextField {
            id: entrySum
            label: qsTr("Starting Balance")
            placeholderText: qsTr("Enter start saldo")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
        }
    }

    Component.onCompleted: { comboCategory.currentIndex = 0; }
}
