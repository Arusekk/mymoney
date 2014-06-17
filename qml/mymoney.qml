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
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property string errorText: ""
    onErrorTextChanged: { timerHot.start(); hot.opacity = 1.0; }

    Timer {
        id: timerHot
        repeat: false
        interval: 3000
        running: false
        onTriggered: hot.opacity = 0.0
    }

    Rectangle {
        id: hot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.itemSizeLarge
        color: Theme.highlightColor
        opacity: 0.0

        Label {
            anchors.centerIn: parent
            text: errorText
        }
    }

    Connections{
        target: jsonloader
        onError: error
    }

    ListModel
    {
        id: modelTypes
        function load(jsonCat)
        {
            for (var key in jsonCat)
            {
                modelTypes.append({"category" : jsonCat[key].category, "banktype" : jsonCat[key].banktype})
            }
        }
    }

    ListModel {
        id: modelCategorys
        function load(jsonCat)
        {
            for (var key in jsonCat)
            {
                modelCategorys.append({"category" : key})
            }
        }

        function lookupIndex(cat)
        {
            var index = 0;
            for (;index < modelCategorys.count; index++)
            {
                var str = modelCategorys.get(index).category;
                if (str.substr(1, str.length) == cat)
                    return index;
            }
            return -1;
        }
    }

    ListModel
    {
        id: modelBanks

        function load(jsonObject)
        {
            console.log(jsonObject)
            for (var key in jsonObject)
            {
                var arr = jsonObject[key]
                add(arr["category"], arr["title"], arr["banktype"], arr["sum"], arr["md5"])
            }
        }

        function add(cat, title, typ, sum, md)
        {
            var fromfile = true
            var d = new Date()
            if (md == "")
            {
                fromfile = false;
                md = Qt.md5(d.toString())
                console.log("new md "+md)
            }

            var o = {"md5" : md, "category": cat, "banktype" : typ, "title" : title, "sum" : sum}
            for (var i = 0; i < modelBanks.count; i++)
            {
                if (modelBanks.get(i).category.localeCompare(cat) >= 0)
                {
                    modelBanks.insert(i, o)
                    break;
                }
            }

            if (i == modelBanks.count)
                modelBanks.append(o)

            if (!fromfile)
                jsonloader.addAccount(title, cat, typ, sum, md)
        }

        function lookupByMd5(_md5)
        {
            if (_md5 == "")
                return undefined

            var index = 0;
            for (;index < modelBanks.count; index++)
            {
                var o = modelBanks.get(index)
                if (o.md5 == _md5)
                    return o;
            }

            return undefined;
        }

        function addOrChange(cat, title, typ, sum, _md5)
        {
            var o = lookupByMd5(_md5);
            if (o == undefined)
            {
                add(cat, title, typ, sum, "");
            }
            else
            {
                o.category = cat
                o.title = title
                o.banktype = typ
                o.sum = sum
            }


        }
    }

    Component.onCompleted: {
        var txt = jsonloader.load()
        console.log(txt)
        var jsonObject = JSON.parse(txt)
        console.log(jsonObject.categorys)
        modelCategorys.load(jsonObject.categorys)
        modelTypes.load(jsonObject.types)
        modelBanks.load(jsonObject.accounts)
    }
}


