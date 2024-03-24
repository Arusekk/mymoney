import QtQuick 2.1
import Sailfish.Silica 1.0
Page
{
    id: page
    onStatusChanged: {  if (status == PageStatus.Active) items.load(); }
    PageHeader { id: header; title: qsTr("Graph"); height: Theme.itemSizeSmall; }
    Timer {
        id: wrapUpdate
        repeat: false
        interval: 100
        onTriggered: pie.requestPaint()
    }

    CurrencyModel {
        id: modelCurrency
    }
    ComboBox {
        id: combo
        anchors.top: header.bottom
        currentIndex: 0
        label: qsTr("Show")
        onCurrentIndexChanged: items.load()
        menu: ContextMenu {
            MenuItem { text: qsTr("Expenses")}
            MenuItem { text: qsTr("Expenses vs Bank")}
        }
    }
    ListModel {
        id: items
        property double total: 0.0
        property int len: 0
        property var colors: ["red", "green", "blue", "burlywood", "yellow", "magenta", "cyan", "white", "gray", "brown","darksalmon","darkviolet", "mintcream","pink","red", "green"]
        function load()
        {
            items.clear()
            len = 0
            total = 0.0
            for (var i = 0;i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                if (o.currency == defaultCurrency)
                    filterAccount(o);
            }

            // always repaint (clear old)
            wrapUpdate.start()
        }
        function filterAccount(o)
        {
            if (combo.currentIndex == 0)
            {
                if (o.group == "2" && o.sum)
                {
                    items.append({"sum" : o.sum, "color" : colors[len & 0x0F], "title" : o.title})
                    len++
                    total += o.sum
                }
            }
            else if (combo.currentIndex == 1 && o.group != "0")
            {
                if (items.count == 0)
                {
                    items.append({"sum" : 0, "color" : "green", "title" : qsTr("Bank")})
                    items.append({"sum" : 0, "color" : "red", "title" : qsTr("Expenses")})
                    len = 2
                }
                var c;
                if (o.group == "1") // bank
                    c = items.get(0);
                else // Expense
                    c = items.get(1);

                c.sum += o.sum
                total += o.sum
            }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: combo.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.paddingLarge
        anchors.rightMargin: Theme.paddingLarge

        Label {
            id: labelAttention
            visible: items.count == 0
            text: qsTr("Attention! Only accounts with currency '%1' will be shown in graph and cover.").arg(modelCurrency.lookupTitleByLocale(defaultCurrency))
            height: Theme.itemSizeVeryLarge//+Theme.itemSizeSmall
            wrapMode: Text.WordWrap
            width: parent.width-Theme.paddingLarge*2 // wordwrap "hack"
            color: Theme.highlightColor
            x: Theme.paddingLarge // wordwrap "hack"
        }
        Grid {
            id: grid
            rows: 10
            columns: 2
            spacing: 2
            height: (Math.round(items.count/2) + 2) *  Theme.fontSizeSmall
            width: parent.width
            Repeater {
                model: items
                Row
                {
                    property int rec_size: Theme.fontSizeSmall*0.90
                    height: Theme.fontSizeSmall
                    width: grid.width/grid.columns
                    spacing: 3
                    Rectangle {
                        id: rect
                        width: rec_size
                        height: Theme.fontSizeSmall*0.90
                        color: model.color
                    }

                    Label {
                        //.x: 40
                        width: parent.width-rec_size
                        font.pixelSize: Theme.fontSizeSmall
                        text: title+" "+((sum/items.total)*100).toFixed(1)+"%"
                    }
                }
            }
        }

        Canvas {
            id: pie
            visible: items.count
            width: parent.width*0.75
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            property int centerX: height/2
            property int centerY: height/2
            property int radius: width/2
            onPaint: {
                var percent = 0.0
                var segment = 0.0
                var ctx = getContext("2d")
                for (var i = 0; i < items.count; i++)
                {
                    ctx.beginPath();
                    var o = items.get(i);
                    ctx.fillStyle = o.color
                    ctx.moveTo(centerX, centerY)
                    percent = ((o.sum/items.total) * Math.PI * 2)
                    ctx.arc(centerX, centerY, radius, segment, segment + percent);
                    segment += percent
                    ctx.closePath()
                    ctx.fill();
                    //break
                }
            }
        }

    }

}
