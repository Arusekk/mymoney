import QtQuick 2.1
import Sailfish.Silica 1.0
Page {
    property string md5: ""
    property var account

    Connections
    {
        target: app
        onTransactionsUpdated: modelCurrentTransactions.load()
    }

    QtObject{
        // we need to make a copy of every transaction when insert in currentModel since we modify sum
        // this probadly can be done better...
        id: item
        property double sum: 0.0
        property double sum2: 0.0
        property string description: ""
        property string to: ""
        property string from: ""
        property string date: ""
    }
    ListModel {
        id: modelCurrentTransactions
        function load()
        {
            modelCurrentTransactions.clear()
            var isbank = modelAccounts.lookupByMd5(md5).group == "1"
            account = modelAccounts.lookupByMd5(md5)
            var tr = modelTransactions.transactions
            console.log(tr)
            for (var key in tr)
            {
                var o = tr[key]
                if (o.from == md5)
                {
                    // invert sum only if bank is from
                    modelCurrentTransactions.dirtyInsert(o, isbank)
                }
                else if(o.to == md5)
                {
                    modelCurrentTransactions.dirtyInsert(o, false)
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

        function dirtyInsert(n, invertsum) // this probadly could be done better...
        {
            // we need to make a copy of the original since we modify sum
            item.sum = n.sum
            item.sum2 = 0.0
            item.description = n.description
            item.to = n.to
            item.from = n.from
            item.date = n.date
            if (invertsum){
                // and now the real reason we copy...
                item.sum = item.sum * -1
            }
            for (var i = 0; i < modelCurrentTransactions.count; i++)
            {
                var o = modelCurrentTransactions.get(i)
                var d1 = new Date(n.date).getTime()
                var d2 = new Date(o.date).getTime()
                if (d1 <= d2)
                {
                    modelCurrentTransactions.insert(i, item)
                    break;
                }
            }
            if (i == modelCurrentTransactions.count) {
                modelCurrentTransactions.append(item)
            }

        }
    }

    SilicaListView{
        id: listView
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        header: PageHeader { id: header; title: qsTr("Transactions %1").arg(modelAccounts.lookupByMd5(md5).title) }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add transaction")
                onClicked: {
                    if (account.group != "2")
                        pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { transaction:  { "from" : md5, "group" : account.group, "sum" : 0.0, "description" : "" } })
                    else
                        pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { transaction:  {  "to" : md5, "group" : account.group, "sum" : 0.0, "description" : "" } })
                }
            }
        }

        clip: true
        model: modelCurrentTransactions
        delegate: TransactionDelegate {}
        VerticalScrollDecorator { flickable:listView }
    }

    Component.onCompleted: modelCurrentTransactions.load()
}
