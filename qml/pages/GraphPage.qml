import QtQuick 2.1
import Sailfish.Silica 1.0
Page
{
    id: page
    PageHeader { id: header; title: qsTr("Graph"); }
    ComboBox {
        id: combo
        anchors.top: header.bottom
//        height: Theme.itemSizeSmall
        currentIndex: -1
        label: qsTr("Show")
        onCurrentIndexChanged: items.load()
        menu: ContextMenu {
            MenuItem { text: qsTr("Expense")}
            MenuItem { text: qsTr("Expense vs Bank")}
        }
    }
    ListModel {
        id: items
//        property var objects: []
        property double total: 0.0
        property int len: 0
        property var colors: ["red", "green", "blue", "burlywood", "yellow", "magenta", "cyan","black", "white", "gray", "brown","darksalmon","darkviolet", "mintcream","pink"]
        function load()
        {
            items.clear()
            len = 0
            total = 0.0
            var len = 0
            for (var i = 0;i < modelAccounts.count; i++)
            {
                var o = modelAccounts.get(i)
                filterAccount(o);
            }

            pie.requestPaint()
        }
        function filterAccount(o)
        {
            if (combo.currentIndex == 0)
            {
                if (o.group == "2" && o.sum)
                {
                    items.append({"sum" : o.sum, "color" : colors[len], "title" : o.title})
                    len++
                    total += o.sum
                }
            }
            else if (combo.currentIndex == 1 && o.group != "0")
            {
                if (items.count == 0)
                {
                    items.append({"sum" : 0, "color" : "green", "title" : qsTr("Bank")})
                    items.append({"sum" : 0, "color" : "red", "title" : qsTr("Expense")})
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
        Grid {
            id: grid
            rows: 7
            columns: 2
            spacing: 2
            height: 340
            width: parent.width
            Repeater {
                model: items
               // height: 280
                Item
                {
                    height: 40
                    width: grid.width/grid.columns
//                    width: parent.width
                    Rectangle {
                        id: rect
                        width: 32
                        height: 32
                        color: model.color
                    }
                    Label {
                        x: 40
                        font.pixelSize: Theme.fontSizeSmall
                      //  anchors.horizontalCenter: parent.horizontalCenter
                        text: title+" "+((sum/items.total)*100).toFixed(1)+"%"
                    }
                }
            }
        }

        Canvas {
            id: pie
            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.centerIn: parent
            width: 300
            height: 300
            property int centerX: height/2
            property int centerY: height/2
            property int radius: 150
            onPaint: {
                var percent = 0.0
                var segment = 0.0
                var ctx = getContext("2d")
/*                ctx.fillStyle = 'green'
                ctx.strokeStyle = "blue"
                ctx.lineWidth = 4
                ctx.beginPath();
                ctx.moveTo(centerX, 0);
                ctx.lineTo(centerX, height);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(0, centerY);
                ctx.lineTo(height, centerY);
                ctx.stroke();
                ctx.strokeStyle = "black"
                ctx.strokeRect(0,0, 300, 300)
                */
                for (var i = 0; i < items.count; i++)
                {
                    ctx.beginPath();
                    ctx.moveTo(centerX, centerY)
                    var o = items.get(i);
                    percent = ((o.sum/items.total) * Math.PI * 2)
                    console.log("paintsegstart "+segment)
                    console.log("paintsegend "+percent)
                    console.log(o.color)
                    ctx.fillStyle = o.color
                    ctx.arc(centerX, centerY, radius, segment, segment + percent);
                    segment += percent
                    ctx.closePath()
                    ctx.fill();
                    ctx.beginPath();
                    //break
                }
                ctx.fill()
            }
        }
    }

    Component.onCompleted: combo.currentIndex = 0
}
