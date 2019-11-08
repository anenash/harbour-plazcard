import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label

        anchors.centerIn: parent
        anchors.margins: Theme.paddingSmall
        width: parent.width
        text: main.searchString
        wrapMode: "WordWrap"
        horizontalAlignment: "AlignHCenter"
    }
}
