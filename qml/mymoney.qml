/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: app
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property string currentLocale: Qt.locale().name
    signal transactionsUpdated
    property string errorText: ""
    onErrorTextChanged: { timerHot.start(); hot.opacity = 1.0; }

    Timer {
        id: timerHot
        repeat: false
        interval: 3000
        running: false
        onTriggered: hot.opacity = 0.0
    }

    QtObject{
        id: db
        property var _db: undefined
        function load()
        {
            _db = LocalStorage.openDatabaseSync("MyMoneyDB", "1.0", "Settings", 1000);
            _db.transaction(
                            function(tx) {
                                // Create the database if it doesn't already exist
                                tx.executeSql('CREATE TABLE IF NOT EXISTS Locale(current TEXT)');
                            }
                        )

            _db.transaction(function(tx)
            {
                var rs = tx.executeSql('SELECT current FROM Locale;');
                if(rs.rows.length)
                {
                    currentLocale = rs.rows.item(0).current
                }
            });
        }

        function save()
        {
            _db.transaction(function(tx)
            {
                tx.executeSql('DELETE FROM Locale;')
                tx.executeSql('INSERT OR REPLACE INTO Locale VALUES (?);',[currentLocale])
            });
        }
    }

    Rectangle {
        id: hot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.itemSizeLarge
        color: Theme.highlightColor
        opacity: 0.0
        z: 1
        Label {
            anchors.centerIn: parent
            text: errorText
        }
    }

    Connections
    {
        target: jsonloader
        onError: error
    }

    Connections
    {
        target: transactionmanager
        onError: error
    }

    ListModel
    {
        id: modelAccountTypes
        function load(jsonCat)
        {
            for (var key in jsonCat)
            {
                modelAccountTypes.append({"group" : jsonCat[key].group, "type" : jsonCat[key].type})
            }
        }

        function lookupIndex(typ)
        {
            var index = 0;
            for (;index < modelAccountTypes.count; index++)
            {
                var str = modelAccountTypes.get(index).type;
                if (str.substr(1, str.length) == typ)
                    return index;
            }
            return -1;
        }
    }

    ListModel {
        id: modelAccountGroups
        function load(jsonCat)
        {
            for (var key in jsonCat)
            {
                modelAccountGroups.append({"title" : jsonCat[key], "id" : key})
            }
        }

        function lookupIndex(key)
        {
            var index = 0;
            for (;index < modelAccountGroups.count; index++)
            {
                var o = modelAccountGroups.get(index);
                if (o.id == key)
                    return index;
            }
            return -1;
        }
    }

    QtObject
    {
        id: modelTransactions

        property var transactions
        function load(jsonObject)
        {
            modelTransactions.transactions = jsonObject
        }

        function add(from, to, description, sum)
        {
            transactionmanager.add(from, to, description, sum, true)
            modelTransactions.transactions = JSON.parse(jsonloader.dump()).transactions
            var o = modelAccounts.lookupByMd5(from)
            o.sum = o.sum - sum
            modelAccounts.updateTotal(o.group, (sum * -1))
            o = modelAccounts.lookupByMd5(to)
            o.sum = o.sum + sum
            modelAccounts.updateTotal(o.group, sum)

            transactionsUpdated()
        }
    }

    QtObject{ id: balanceAccount; property string md5; property string group; property string title; property string type; property double sum; }
    ListModel
    {
        id: modelAccounts
        property double saldoIncomes: 0.0
        property double saldoBanks: 0.0
        property double saldoExpenses: 0.0
        function load(jsonObject)
        {
            saldoIncomes = 0.0
            saldoBanks = 0.0
            saldoExpenses = 0.0
            modelAccounts.clear()
            for (var key in jsonObject)
            {
                var arr = jsonObject[key]
                if (arr["group"] != "SB")  // don't show balance account
                {
                    add(arr["group"], arr["title"], arr["type"], arr["sum"], key)
                }
                else
                {
                    balanceAccount.title = arr["title"]
                    balanceAccount.sum = arr["sum"]
                    balanceAccount.group = arr["group"]
                    balanceAccount.type = arr["type"]
                    balanceAccount.md5 = key
                }
            }
        }

        function updateTotal(group, sum)
        {
            if (group == "0")
                saldoIncomes = saldoIncomes + sum
            else if (group == "1")
                saldoBanks = saldoBanks + sum
            else if (group == "2")
                saldoExpenses = saldoExpenses + sum

        }

        function getAccountSaldoAsString(md5)
        {
            var o = lookupByMd5(md5)
            return o ?  o.sum.toLocaleCurrencyString(Qt.locale(currentLocale)) : ""
        }

        function add(group, title, typ, sum, md)
        {
            var d = new Date()
            updateTotal(group, sum)
            var o = {"md5" : md, "group": group, "type" : typ, "title" : title, "sum" : sum}
            console.log(o.md5)
            for (var i = 0; i < modelAccounts.count; i++)
            {
                if (modelAccounts.get(i).group.localeCompare(group) >= 0)
                {
                    modelAccounts.insert(i, o)
                    break;
                }
            }

            if (i == modelAccounts.count)
                modelAccounts.append(o)

        }


        function lookupByMd5(_md5)
        {
            if (_md5 == "")
                return undefined

            if (_md5 == balanceAccount.md5)
                return balanceAccount

            for (var index = 0;index < modelAccounts.count; index++)
            {
                var o = modelAccounts.get(index)
                console.log(_md5+" == "+o.md5)
                if (o.md5 == _md5)
                    return o;
            }

            return undefined;
        }

        function addOrChange(group, title, typ, sum, _md5)
        {
            var o = lookupByMd5(_md5);
            if (!o) // new
            {
                // yes, notice addAcount will add new balancqa transaction...
                _md5 = jsonloader.addAccount(title, group, typ, sum, "")
                // insert in model FIXME we better reread json file less risk for bug
                add(group, title, typ, sum, _md5);
                // ... as we do it on transactions
                var jsonObject = JSON.parse(jsonloader.dump())
                modelTransactions.transactions = jsonObject.transactions
                modelAccounts.load(jsonObject.accounts)
            }
            else
            {
                o.group = group
                o.title = title
                o.type = typ
//                o.sum = sum
                jsonloader.addAccount(title, group, typ, sum, _md5)
            }
        }
    }

    Component.onCompleted: {
        var txt = jsonloader.load()
        console.log(txt)
        console.log(currentLocale)
        var jsonObject = JSON.parse(txt)
        db.load()
        modelAccountGroups.load(jsonObject.accountgroups)
        modelAccountTypes.load(jsonObject.accounttypes)
        modelAccounts.load(jsonObject.accounts)
        modelTransactions.load(jsonObject.transactions)
    }
}


