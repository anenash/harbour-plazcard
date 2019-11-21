import QtQuick 2.4
import Sailfish.Silica 1.0


ListItem {
    property variant ticket: ({})

    anchors.left: parent.left
    contentHeight: Theme.itemSizeHuge + Theme.itemSizeMedium
    width: parent.width

    ListModel {
        id: pricesModel
    }

    QtObject {
        id: internal

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
        source: "image://theme/icon-m-train"
    }
    Label {
        id: trainNum

        anchors.left: icon.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: icon.verticalCenter
        font.bold: true
        text: ticket.trainNumber + " " + ticket.trainName
    }
    Row {
        id: ticketStations

        anchors.top: icon.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: parent.right
        Item {
            id: deph

            height: Theme.itemSizeMedium
            width: parent.width * 0.5

            Text {
                id: depStation0

                text: ticket.depCityName
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
            }
            Text {
                id: depStation1

                anchors.top: depStation0.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                text: ticket.depStationName
                font.pixelSize: Theme.fontSizeTiny
                font.bold: true
                color: Theme.primaryColor
            }
            Text {
                id: depDate

                anchors.top: depStation1.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

                text: new Date(ticket.trainDepartureDateTime*1000).toDateString()
                font.pixelSize: Theme.fontSizeTiny
                font.bold: true
                color: Theme.secondaryColor
            }
            Text {
                id: depTime

                anchors.top: depDate.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

                text: new Date(ticket.trainDepartureDateTime*1000).toTimeString()
                font.pixelSize: Theme.fontSizeExtraSmall
                font.bold: true
                color: Theme.primaryColor
            }
        }
        Item {
            id: arr

            height: Theme.itemSizeMedium
            width: parent.width * 0.5

            Text {
                id: arrStation0

                text: ticket.arrCityName
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
            }
            Text {
                id: arrStation1

                anchors.top: arrStation0.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                text: ticket.arrStationName
                font.pixelSize: Theme.fontSizeTiny
                font.bold: true
                color: Theme.primaryColor
            }
            Text {
                id: arrDate

                anchors.top: arrStation1.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

                text: new Date(ticket.trainArrivalDateTime*1000).toDateString()
                font.pixelSize: Theme.fontSizeTiny
                font.bold: true
                color: Theme.secondaryColor
            }
            Text {
                id: arrTime

                anchors.top: arrDate.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

                text: new Date(ticket.trainArrivalDateTime*1000).toTimeString()
                font.pixelSize: Theme.fontSizeExtraSmall
                font.bold: true
                color: Theme.primaryColor
            }
        }
    }

    Text {
        id: durTime

        anchors.top: ticketStations.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left

        font.pixelSize: Theme.fontSizeExtraSmall
        text: qsTr("Duration: ") + internal.secondsToHms(ticket.tripDuration)
        color: Theme.secondaryColor
    }
    Text {
        id: seatsCount

        anchors.top: durTime.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: ticketPrice.left

        font.pixelSize: Theme.fontSizeExtraSmall
        text: qsTr("Seats: ") + ticket.seatsCount
        color: Theme.secondaryColor
    }
    Label {
        id: ticketPrice

        anchors.top: ticketStations.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        width: parent.width * 0.35
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true
        text: "от " + ticket.minPrice + " " + ticket.currency
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Separator {
        anchors.bottom: parent.bottom
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("RouteInfoPage.qml"), {"routeData": ticket, "prices": ticket.prices})
    }
}
