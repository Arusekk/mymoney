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


Page {
    id: page
    SilicaListView {
        id: bankview
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        header: PageHeader {
            id: header
            height: Theme.itemSizeSmall
            title: appinfo.getName()+" v"+appinfo.getVersion()
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("About %1").arg(appinfo.getName())
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
/*            MenuItem
            {
                text: qsTr("Expense graph")
                onClicked: pageStack.push(Qt.resolvedUrl("GraphPage.qml"))
            }
            */
            MenuItem {
                text: qsTr("Add account")
                onClicked: pageStack.push(Qt.resolvedUrl("AddAccountPage.qml"))
            }
            MenuItem {
                visible: modelAccounts.count > 1
                text: qsTr("Add transaction")
                onClicked: pageStack.push(Qt.resolvedUrl("AddTransactionPage.qml"), { "transaction":  { "md5" : "", "group" : "2", "description" : "", "sum" : 0.0 } })
            }
        }

        clip: true //  to have the out of view items clipped nicely.
        model: modelAccounts

        delegate: BankDelegate {}
        section.criteria: ViewSection.FullString
        section.property: "group"
        section.delegate: Label { font.family: Theme.fontFamilyHeading; color: Theme.highlightColor; text: modelAccountGroups.get(section).title; anchors.horizontalCenter: parent.horizontalCenter; }
        VerticalScrollDecorator { flickable:bankview }
    }

    Column {
        visible: modelAccounts.count < 3
        anchors.centerIn: parent
        Label {
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            text: qsTr("Add accounts from pulley menu")
            height: Theme.itemSizeSmall
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("You should have at least one of each\ngroup (Income, Bank and Expense).")
            height: Theme.itemSizeMedium
        }
    }

    Timer{
        interval: 200
        running: true
        repeat: false
        onTriggered:  pageStack.pushAttached(Qt.resolvedUrl("GraphPage.qml"))
    }
}


