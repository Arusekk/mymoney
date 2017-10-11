import QtQuick 2.0

ListModel {
    ListElement { title: "Euro"; locale : "FI_fi"}
    ListElement { title: "US Dollar"; locale : "en_US"}
    ListElement { title: "Swiss franc"; locale : "de_CH"}
    ListElement { title: "Krona"; locale : "sv_SE"}
    ListElement { title: "Yuan"; locale : "zh"}
    ListElement { title: "British Pound"; locale : "en_GB"}
    ListElement { title: "Romanian Leu"; locale : "ro_RO"}

    function lookupTitleByLocale(locale)
    {
        for (var i = 0;i<count;i++)
        {
            var o = get(i)
            if (o.locale == locale)
            {
                return o.title
            }
        }

        return ""
    }
}
