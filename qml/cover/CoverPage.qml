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

import QtQuick 2.1
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 2

        Item {
            width: parent.width
            height: 12
        }

        Label {
            id: label1
            text: qsTr("Income")
            color: Theme.highlightColor
            font.family: Theme.fontFamilyHeading;
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: sum1
            anchors.horizontalCenter: parent.horizontalCenter
            text: Number(modelAccounts.saldoIncomes * -1).toLocaleCurrencyString(Qt.locale())
        }

        Label {
            id: label2
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Bank")
        }

        Label {
            id: sum2
            anchors.horizontalCenter: parent.horizontalCenter
            text: Number(modelAccounts.saldoBanks).toLocaleCurrencyString(Qt.locale())
        }

        Label {
            id: label3
            color: Theme.highlightColor
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Expenses")
        }

        Label {
            id: sum3
            anchors.horizontalCenter: parent.horizontalCenter
            text: Number(modelAccounts.saldoExpenses).toLocaleCurrencyString(Qt.locale())
        }
    }

    CoverActionList {
        id: coverAction
        enabled: pageStack.depth == 1

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: { pageStack.push(Qt.resolvedUrl("../pages/AddTransactionPage.qml")); app.activate();  }
        }
    }
}


