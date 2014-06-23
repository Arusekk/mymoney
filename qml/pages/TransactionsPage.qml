import QtQuick 2.1
import Sailfish.Silica 1.0
Page {
    property string md5: ""
    property var account
    ListModel {
        id: modelCurrentTransactions
        function load()
        {
            var isbank = modelAccounts.lookupByMd5(md5).group == "1"
            account = modelAccounts.lookupByMd5(md5)
            var tr = modelTransactions.transactions
            console.log(tr)
            for (var key in tr)
            {
                var o = tr[key]
                if (o.from == md5)
                {
                    if (isbank)
                        o.sum = o.sum * -1
                    modelCurrentTransactions.dirtyInsert(o)
                }
                else if(o.to == md5)
                {
                    modelCurrentTransactions.dirtyInsert(o)
                }
            }

            updateSaldos()
        }

        function updateSaldos()
        {
            var total = 0.0
            for (var i = 0; i < modelCurrentTransactions.count; i++)
            {
                var o = modelCurrentTransactions.get(i)
                total = total + o.sum
                o.sum2 = total
            }
        }

        function dirtyInsert(n) // this probadly could be done better...
        {
            n["sum2"] = 0.0
            for (var i = 0; i < modelCurrentTransactions.count; i++)
            {
                var o = modelCurrentTransactions.get(i)
                if (n.date <= o.date)
                {
                    modelCurrentTransactions.insert(i, n)
                    break;
                }
            }
            if (i == modelCurrentTransactions.count) {
                modelCurrentTransactions.append(n)
            }

        }
    }

    SilicaFlickable{
        anchors.fill: parent
        interactive: !listView.flicking
        pressDelay: 0
        PageHeader { id: header; title: qsTr("Transactions %1").arg(modelAccounts.lookupByMd5(md5).title) }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add transaction")
                onClicked: pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { transaction:  { "md5" : md5, "group" : account.group, "sum" : 0.0 } })
            }
        }

        SilicaListView{
            id: listView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: Theme.paddingSmall
            anchors.rightMargin: Theme.paddingSmall
            clip: true
            model: modelCurrentTransactions
            delegate: TransactionDelegate {}
            VerticalScrollDecorator { flickable:listView }
        }
    }
    Component.onCompleted: modelCurrentTransactions.load()
}