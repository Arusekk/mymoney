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

    property var modelCategorysTr:
    [
        { category: qsTr("0Inkomster")  },
        { category: qsTr("1Bank")       },
        { category: qsTr("2Utgifter")   }
    ]

    property var modelTypes:
    [
        { category: qsTr("0Inkomster"), banktype: qsTr("Arbete")},
        { category: qsTr("0Inkomster"), banktype: qsTr("A-Kassa")},
        { category: qsTr("0Inkomster"), banktype: qsTr("Bidrag")},
        { category: qsTr("0Inkomster"), banktype: qsTr("Lån")},
        { category: qsTr("1Bank"), banktype: qsTr("Mastercard")},
        { category: qsTr("1Bank"), banktype: qsTr("VisaCard")},
        { category: qsTr("1Bank"), banktype: qsTr("Sparkonto")},
        { category: qsTr("1Bank"), banktype: qsTr("Lån")},
        { category: qsTr("2Utgifter"), banktype: qsTr("Hem")}
    ]

    ListModel {
        id: modelCategorys
        function load()
        {
            for (var i = 0; i < modelCategorysTr.length; i++)
            {
                modelCategorys.append({"category" : modelCategorysTr[i].category})
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

        function load()
        {
            modelBanks.add(modelCategorys.get(0).category, "Jobb", "Lön", 0.0)
            modelBanks.add(modelCategorys.get(1).category, "Ica", "Mastercard", 4321.56);
            modelBanks.add(modelCategorys.get(1).category, "Sparbanken", "Mastecard", 0.0);
            modelBanks.add(modelCategorys.get(1).category, "Coop", "Medlemskort", 0.0);
            modelBanks.add(modelCategorys.get(2).category, "Hyra", "Hem", 0.0)
            modelBanks.add(modelCategorys.get(0).category, "Jobb2", "Lön", 0.0)
        }

        function add(cat, title, typ, sum)
        {
            var d = new Date()
            for (var i = 0; i < modelBanks.count; i++)
            {
                if (modelBanks.get(i).category.localeCompare(cat) >= 0)
                {
                    modelBanks.insert(i, {"md5" : Qt.md5(d.toString()), "category": cat, "banktype" : typ, "title" : title, "sum" : sum})
                    console.log(i)
                    return  ;
                }
            }
            modelBanks.append({"md5" : Qt.md5(d.toString()), "category": cat, "banktype" : typ, "title" : title, "sum" : sum})
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
                add(cat, title, typ, sum);
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
        modelCategorys.load()
        modelBanks.load()
    }
}


