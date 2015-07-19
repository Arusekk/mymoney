import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    id: search
    property QtObject filter
    property string currency: ""
    onStatusChanged: {
        if (status == PageStatus.Active)
            entrySum.forceActiveFocus()
    }

    Column {
        anchors.fill: parent
        PageHeader {
            title: qsTr("Search filter")
        }

        TextField{
            id: entrySum
            text: ""
            label: qsTr("Amount")
            placeholderText: qsTr("Enter amount")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator { decimals: 2; }
            width: parent.width
            EnterKey.enabled: true
            EnterKey.onClicked: entryDescription.focus = true
            onTextChanged: filter.sum = asDouble()
            function asDouble()
            {
                return text != "" ? Number.fromLocaleString(Qt.locale(currency), text) : 0.0
            }
        }

        TextField
        {
            id: entryDescription
            label: qsTr("Description")
            width: parent.width
            placeholderText: qsTr("Enter description to search for")
            onTextChanged: filter.description = entryDescription.text
        }
    }
}
