import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem  {
    id: background
    anchors.left: ListView.left
    anchors.right: ListView.right
    height: Theme.itemSizeSmall
    contentHeight: Theme.itemSizeSmall

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

    Column{
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        Label {
            font.pixelSize: Theme.fontSizeSmall
            //color: getTitleColor()
            //font.bold: model.title
            text: model.title
        }

        Row {
            Label {
                id: authorLabel
                font.pixelSize: Theme.fontSizeSmall
                text: banktype
            }

            // Fill some space before statics rectangles
            Rectangle {
                id: fillRectangel
                color: "transparent"
                width: background.width - authorLabel.width - timesRectangle.width
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
                    text: Number(sum).toLocaleCurrencyString()
                }
            }



        }
    }
}
