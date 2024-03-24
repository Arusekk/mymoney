import QtQuick 2.1
import Sailfish.Silica 1.0
Page {
    id: transactionsPage
    property string md5: "" // md5 of account
    property var account
    property string group: ""
    property string currency: modelAccounts.lookupByMd5(md5).currency
    Connections
    {
        target: app
        onTransactionsUpdated: modelCurrentTransactions.load()
    }

    onStatusChanged: { if (status == PageStatus.Active) modelCurrentTransactions.load(); }

    QtObject{
        // we need to make a copy of every transaction when insert in currentModel since we modify sum
        // this probadly can be done better...
        id: item
        property string md5: "" // transactionmd5
        property double sum: 0.0
        property double sum2: 0.0
        property string description: ""
        property string to: ""
        property string from: ""
        property string date: ""
    }

    QtObject {
        id: filter
        property double sum: 0.0
        property string description: ""
    }

    ListModel {
        id: modelCurrentTransactions
        function load()
        {
            modelCurrentTransactions.clear()
            var isbank = modelAccounts.lookupByMd5(md5).group == "1"
            account = modelAccounts.lookupByMd5(md5)
            var tr = modelTransactions.transactions
            for (var key in tr)
            {
                var o = tr[key]
                if (o.from == md5)
                {
                    // invert sum only if bank is from
                    modelCurrentTransactions.dirtyInsert(key, o, isbank)
                }
                else if(o.to == md5)
                {
                    modelCurrentTransactions.dirtyInsert(key, o, false)
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

        function dirtyInsert(key, n, invertsum) // this probadly could be done better...
        {
            // filter "active" if not 0.0
            if (filter.sum && n.sum != filter.sum)
                return

            // description
            if (filter.description != "" && n.description.search(new RegExp(filter.description, "i")) == -1)
                return

            // we need to make a copy of the original since we modify sum
            item.sum = n.sum
            item.sum2 = 0.0
            item.description = n.description
            item.to = n.to
            item.from = n.from
            item.date = n.date
            item.md5 = key
            var nd = new Date(n.date).getTime()
            var td = new Date()
            td.setMonth(td.getMonth()-latestMonths)
            if (nd < td)
                return ;

            if (invertsum){
                // and now the real reason we copy...
                item.sum = item.sum * -1
            }

            insertSorted(item, nd)
        }

        function insertSorted(item, nd)
        {
            for (var i = 0; i < modelCurrentTransactions.count; i++)
            {
                // this feels akward could we get object direct instead of index?
                var o = modelCurrentTransactions.get(i)
                var d = new Date(o.date).getTime()
                if (nd <= d)
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
        header: PageHeader { id: header; title: modelAccounts.lookupByMd5(md5).title+": "+modelAccounts.getAccountSaldoAsString(md5) }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add transaction")
                onClicked: {
                    if (account.group != "2")
                        pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { transaction:  { "from" : md5, "md5" : "", "group" : account.group, "sum" : 0.0, "description" : "" } })
                    else
                        pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { transaction:  {  "to" : md5, "md5" : "", "group" : account.group, "sum" : 0.0, "description" : "" } })
                }
            }
            MenuItem {
                text: qsTr("Clear filter")
                visible: filter.sum || filter.description != ""
                onClicked: {
                    filter.sum = 0.0
                    filter.description = ""
                    modelCurrentTransactions.load()
                }
            }
        }

        clip: true
        model: modelCurrentTransactions
        delegate: TransactionDelegate {}
        VerticalScrollDecorator { flickable:listView }
    }

    Timer{
        interval: 800
        running: true
        onTriggered: pageStack.pushAttached(Qt.resolvedUrl("SearchTransactionPage.qml"), {"currency" : currency, "filter" : filter});
    }
}
