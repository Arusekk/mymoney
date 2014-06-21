import QtQuick 2.1
import Sailfish.Silica 1.0
BackgroundItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    contentHeight: Theme.itemSizeSmall
    height: menuOpen ? contextMenu.height + Theme.itemSizeSmall : Theme.itemSizeSmall

    property bool menuOpen: contextMenu != null && contextMenu.parent === background
    property Item contextMenu
    onClicked: {
    }

    function getTitleColor() {
        var color = Theme.primaryColor
        // If item selected either from list or Cover, make color highlighted
        if (background.highlighted ||
            (index === coverProxy.currentQuestion - 1)) {
            color = Theme.highlightColor
        }
        return color
    }
    onPressAndHold: {
                   if (!contextMenu)
                       contextMenu = contextMenuComponent.createObject(bankview)
                   contextMenu.show(background)
               }
    Component
    {
        id: contextMenuComponent
        ContextMenu {
            MenuItem {
                text: qsTr("Edit account")
                onClicked: pageStack.push(Qt.resolvedUrl("AddAccountPage.qml"), { account : modelAccounts.lookupByMd5(model.md5)})
            }
            MenuItem {
                text: qsTr("Show transactions")
                onClicked: pageStack.push(Qt.resolvedUrl("TransactionsPage.qml"), { md5 : model.md5})
            }
        }
    }

    Column{
        id: myListItem
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        Row {
            Label {
                id: labelTitle
                font.pixelSize: Theme.fontSizeSmall
                //color: getTitleColor()
                //font.bold: model.title
                text: title
            }
            Item {
                id: fillRectangel
//                color: "transparent"
                width: background.width - labelTitle.width - timesRectangle.width
                height: 40
            }

            // Created and updated time strings
            Rectangle {
                id: timesRectangle
                color: "transparent"
                width: 160
                height: 40
                Label {
                    font.pixelSize: Theme.fontSizeSmall
                    anchors.fill: parent
                    text: Number(group != "0" ? sum : (sum * -1)).toLocaleCurrencyString(Qt.locale())
                }
            }
        }
        Row {
            Label {
                id: labelType
                font.pixelSize: Theme.fontSizeSmall
                font.italic: true
                color: Theme.secondaryColor
                text: type
            }

            // Fill some space before statics rectangles



        }
    }
}
