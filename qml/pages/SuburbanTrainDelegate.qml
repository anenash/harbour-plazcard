import QtQuick 2.4
import Sailfish.Silica 1.0

ListItem {
    property variant info: ({})

    //    anchors.left: parent.left
    contentHeight: Theme.itemSizeHuge
    width: Screen.width

    Icon {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin

        color: Theme.primaryColor
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        source: "image://theme/icon-m-train"
    }

    Text {
        id: trainNum

        anchors.left: icon.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: icon.verticalCenter
        horizontalAlignment: Text.AlignRight
        font.bold: true
        color: Theme.primaryColor
        text: "\u2116 " + info.trainNum
    }

    Text {
        id: occation

        anchors.left: trainNum.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: icon.verticalCenter
        horizontalAlignment: Text.AlignRight
        color: Theme.primaryColor
        text: info.days
    }

    Item {
        id: dep

        anchors.top: icon.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        height: Theme.itemSizeMedium
        width: parent.width * 0.5

        Text {
            id: departureStation

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            text: info.departureStation
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignRight
        }

        Text {
            id: departureTime

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            text: new Date(info.departureTime).toTimeString()
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignRight
        }
    }

    Item {
        id: arr

        anchors.top: icon.bottom
        anchors.left: dep.right
        anchors.leftMargin: Theme.horizontalPageMargin
        height: Theme.itemSizeMedium
        width: parent.width * 0.5

        Text {
            id: arrivalStation

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            text: info.arrivalStation
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            wrapMode: Text.WordWrap
        }

        Text {
            id: arrivalTime

            anchors.bottom: parent.bottom
            text: new Date(info.arrivalTime).toTimeString()
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Separator {
        anchors.bottom: parent.bottom
    }
}
