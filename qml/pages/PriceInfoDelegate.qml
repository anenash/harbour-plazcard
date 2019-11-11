import QtQuick 2.4
import Sailfish.Silica 1.0

ListItem {
    property variant pricesInfo: ({})

    contentHeight: Theme.itemSizeLarge


    function getCarType(type) {
        switch(type) {
        case "coupe":
            return qsTr("Coupe")
        case "plazcard":
            return qsTr("Plazcard")
        case "lux":
            return qsTr("Lux")
        case "sedentary":
            return qsTr("Sedentary")
        case "soft":
            return qsTr("Soft")
        }
    }

    Label {
        id: typeOfSeats

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor
        text: qsTr("Type: ") + getCarType(type)
    }

    Text {
        id: topSeats

        visible: type !== "sedentary"
        anchors.top: typeOfSeats.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: qsTr("Top seats: <b>") + topSeatsCount + "</b>"
    }
    Text {
        id: topPrice

        visible: topSeats.visible && topSeatsCount > 0
        anchors.top: typeOfSeats.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: qsTr("Price: <b>") + topSeatsPrice + "</b> " + currency
    }

    Text {
        id: bottomSeats

        anchors.top: topSeats.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: (type !== "sedentary")?qsTr("Bottom seats: <b>") + bottomSeatsCount + "</b>":qsTr("Seats: <b>") + seatsCount + "</b>"
    }
    Text {
        id: bottomPrice

        anchors.top: topSeats.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        text: (type !== "sedentary")?qsTr("Price: <b>") + bottomSeatsPrice + "</b> " + currency:qsTr("Price: <b>") + price + "</b> " + currency
    }
    Separator {
        anchors.bottom: parent.bottom
    }
}
