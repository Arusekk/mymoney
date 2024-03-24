import QtQuick 2.1
import Sailfish.Silica 1.0
BackgroundItem  {
    id: background
    property int calc_h: Theme.fontSizeSmall*4
    anchors.left: ListView.left
    anchors.right: ListView.right
    contentHeight: calc_h
    height: menuOpen ? contextMenu.height + calc_h : calc_h

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
                       contextMenu = contextMenuComponent.createObject(listView)
                   contextMenu.show(background)
               }
    Component
    {
        id: contextMenuComponent
        ContextMenu {
            MenuItem {
                text: model.from == jsonloader.getBalanceAccountMd5() ? qsTr("Change incoming saldo") : qsTr("Change transaction")
                onClicked: {
                    if (model.from == jsonloader.getBalanceAccountMd5())
                        pageStack.push(Qt.resolvedUrl("AddAccountPage.qml"), { account : modelAccounts.lookupByMd5(model.to)})
                    else
                        pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { "transaction": {"md5" : model.md5, "group" : transactionsPage.group, "from" : model.from, "to" : model.to, "description" : model.description, "sum" : Math.abs(model.sum)}})
                }
            }
        }
    }

    Column{
        id: myListItem
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        spacing: 2
        Row {
            width: parent.width
            height: Theme.fontSizeSmall
            Label {
                id: labelDate
                font.pixelSize: Theme.fontSizeSmall
                text: date
                width: parent.width*0.72
                height: Theme.fontSizeSmall
            }

            Label {
                id: dateValue
                height: Theme.itemSizeSmall
                width: parent.width*0.28
                font.pixelSize: Theme.fontSizeSmall
                text: Number(sum).toLocaleCurrencyString(Qt.locale(currency))
            }
        }

        Label {
            id: labelTitle
            width: parent.width
            height: Theme.fontSizeSmall
            text: getAccountTitle()
            function getAccountTitle()
            {
                if (md5 == from)
                {
                    var o = modelAccounts.lookupByMd5(to)
                    if (!o)
                        return to

                    return o.title
                }
                else
                {
                    var o = modelAccounts.lookupByMd5(from)
                    if (!o)
                        return from

                    return o.title
                }
            }
        }

        Row {
            width: parent.width
            height: Theme.itemSizeSmall
            Label {
                id: labelType
                font.pixelSize: Theme.fontSizeSmall
                font.italic: true
                color: Theme.secondaryColor
                text: description
                width: parent.width*0.72
            }

            Label {
                id: labelSum2
                height: Theme.itemSizeSmall
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width*0.28
                text: Number(sum2).toLocaleCurrencyString(Qt.locale(currency))
            }
        }
    }

    Item {
        height: Theme.fontSizeSmall
        width: parent.width
    }
}
