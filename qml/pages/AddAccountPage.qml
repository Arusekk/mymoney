import QtQuick 2.0
import Sailfish.Silica 1.0
Dialog {
    id: page
    anchors.fill: parent
    DialogHeader {  id: header; title: qsTr("Add Account") }
    property string title

    ListModel {
        id: modelCurrentTypes
        function load(allowed)
        {
            modelCurrentTypes.clear()
            for (var i = 0; i < modelTypes.length; i++)
            {
                if (modelTypes[i].category == allowed)
                {
                    modelCurrentTypes.append({"title" : modelTypes[i].banktype})
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
            text: title
            label: qsTr("Name")
            placeholderText: qsTr("Type name here")
            width: parent.width
        }

        ComboBox
        {
            label: qsTr("Category")
            menu:ContextMenu{
                                Repeater {
                                    model: modelCategorys;
                                    MenuItem { text: category.substr(1, category.length);}
                                }
                            }
            onCurrentIndexChanged: modelCurrentTypes.load(modelCategorys.get(currentIndex).category)
        }

        ComboBox
        {
            label: qsTr("Type")
            menu:ContextMenu{
                                Repeater {
                                    model: modelCurrentTypes;
                                    MenuItem { text: title; }
                                }
                            }
        }

        TextField {
            label: qsTr("Starting Balance")
            placeholderText: qsTr("Enter start saldo")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
        }
    }
}
