import QtQuick 2.2
import Sailfish.Silica 1.0

ListItem {
    property variant ticket: ({})

    anchors.left: parent.left
    contentHeight: Theme.itemSizeHuge + Theme.itemSizeSmall
    width: parent.width

    ListModel {
        id: pricesModel
    }

    QtObject {
        id: internal

        property bool expanded: false

        function secondsToHms(d) {
            d = Number(d)
            var h = Math.floor(d / 3600)
            var m = Math.floor(d % 3600 / 60)

            var hDisplay = h + qsTr(" h ")
            var mDisplay = m + qsTr(" m")
            return hDisplay + mDisplay;
        }
    }

    Icon {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin

        color: Theme.primaryColor
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        source: "../images/train.svg"
    }
    Label {
        id: trainNum

        anchors.left: icon.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: icon.verticalCenter
        font.bold: true
        text: ticket.trainNumber + " " + ticket.trainName
    }
    Text {
        id: depStation

        anchors.top: icon.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left
        text: ticket.departureStation
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.primaryColor
    }
    Text {
        id: depTime

        anchors.top: depStation.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left

        text: new Date(ticket.trainDepartureDateTime*1000).toTimeString() + " " + new Date(ticket.trainDepartureDateTime*1000).toDateString()
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
    }
    Text {
        id: arrStation

        anchors.top: depTime.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left
        text: ticket.arrivalStation
        color: Theme.primaryColor
    }
    Text {
        id: arrTime

        anchors.top: arrStation.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left

        text: new Date(ticket.trainArrivalDateTime*1000).toTimeString() + " " + new Date(ticket.trainArrivalDateTime*1000).toDateString()
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
    }
    Text {
        id: durTime

        anchors.top: arrTime.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left

        font.pixelSize: Theme.fontSizeExtraSmall
        text: qsTr("Duration: ") + internal.secondsToHms(ticket.tripDuration)
        color: Theme.secondaryColor
    }
    Label {
        id: ticketPrice

        anchors.top: trainNum.bottom
        anchors.right: parent.right
        width: parent.width * 0.2
        font.bold: true
        text: "от\n" + ticket.minPrice + "\n" + ticket.currency
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
//    ListView {
//        id: tickets

//        anchors.top: durTime.bottom
//        anchors.left: parent.left
//        anchors.leftMargin: Theme.horizontalPageMargin
//        anchors.right: parent.right
//        anchors.rightMargin: Theme.horizontalPageMargin
//        anchors.bottom: buyButton.top
//        spacing: Theme.paddingMedium
//        visible: internal.expanded
////        width: parent.width
////        height: Theme.itemSizeLarge
//        orientation: Qt.Horizontal//ListView.Horizontal
//        model: ticket.prices //pricesModel

//        delegate: Item {
//            width: seats.width * 1.25
//            height: Theme.itemSizeMedium
//            Text {
//                id: seats

//                font.pixelSize: Theme.fontSizeExtraSmall
//                color: Theme.secondaryColor
//                text: qsTr("Seats: ") + seatsCount
//            }
//            Label {
//                anchors.bottom: parent.bottom

//                font.pixelSize: Theme.fontSizeExtraSmall
//                color: Theme.secondaryColor
//                text: qsTr("Price: ") + price
//            }
//        }
//    }

//    Button {
//        id: buyButton

//        visible: internal.expanded
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: Theme.paddingSmall
//        anchors.horizontalCenter: parent.horizontalCenter
//        text: qsTr("Buy")

//        onClicked: {
//            var url = ticketsInfo.getBuyUrl(ticket.buyUrl)
//            console.log(url)
//            pageStack.push(Qt.resolvedUrl("WebPage.qml"), {pageUrl: url})
//        }
//    }

    Separator {
        anchors.bottom: parent.bottom
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("RouteInfoPage.qml"), {data: ticket, prices: ticket.prices})
//        internal.expanded = !internal.expanded

//        if(internal.expanded) {
//            contentHeight = Theme.itemSizeHuge * 2  + Theme.itemSizeMedium
//        } else {
//            contentHeight = Theme.itemSizeHuge  + Theme.itemSizeSmall
//        }
    }
}
