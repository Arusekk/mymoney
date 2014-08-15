import QtQuick 2.0
import QtQuick.Controls 1.2
ListView
{
    model: modelAccounts
    delegate: BankDelegate { }
}
