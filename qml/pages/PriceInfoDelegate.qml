import QtQuick 2.4
import Sailfish.Silica 1.0

ListItem {
    property variant pricesInfo: ({})

    contentHeight: Theme.itemSizeLarge

    Label {
        id: typeOfSeats

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
        text: qsTr("Type: ") + type
    }

    Text {
        id: topSeats

        visible: type !== "sedentary"
        anchors.top: typeOfSeats.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: qsTr("Top seats: ") + topSeatsCount
    }
    Text {
        id: topPrice

        visible: topSeats.visible && topSeatsCount > 0
        anchors.top: typeOfSeats.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: qsTr("Price: ") + topSeatsPrice + " " + currency
    }

    Text {
        id: bottomSeats

        anchors.top: topSeats.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: (type !== "sedentary")?qsTr("Bottom seats: ") + bottomSeatsCount:qsTr("Seats: ") + seatsCount
    }
    Text {
        id: bottomPrice

        anchors.top: topSeats.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: (type !== "sedentary")?qsTr("Price: ") + bottomSeatsPrice + " " + currency:qsTr("Price: ") + price + " " + currency
    }
    Separator {
        anchors.bottom: parent.bottom
    }
}
