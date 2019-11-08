import QtQuick 2.4
import Sailfish.Silica 1.0

import plazcard.Info 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    property variant routeData: ({})
    property variant prices: ({})

    Component.onCompleted: {
        routeInfo.getRoute(routeData.routeInfo)
    }

    QtObject {
        id: internal

        function getDescription(arrival, stay, departure) {
            var result = ""
            if (arrival && arrival !== "") {
                result += "\u29D1 " + arrival
            }
            if (stay && stay !== "") {
                result += " \u29D3 " + stay.replace("&nbsp;", " ");
            }
            if (departure && departure !== "") {
                result += " \u29D2 " + departure
            }

            return result
        }

        function getIcon(arrival, departure) {
            if (arrival !== "" && departure !== "") {
                return "image://theme/icon-m-device"
            } else if (arrival !== "") {
                return "image://theme/icon-m-device-upload"
            } else {
                return "image://theme/icon-m-device-download"
            }
        }
    }

    Info {
        id: routeInfo

        onRouteModelChanged: {
            for (var i in routeInfo.routeModel) {
                routeModel.append(routeInfo.routeModel[i].data)
            }
        }
    }

    ListModel {
        id: routeModel
    }

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header

            width: page.width

            anchors.top: parent.top
            title: qsTr("Information")
        }

        SilicaListView {
            id: routeInfoView

            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            height: parent.height * 0.33
            clip: true

            model: routeModel

            delegate: PageHeader {
                title: name
                description: internal.getDescription(arrivalTime, stayTime, departureTime)
                extraContent.children: [
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: internal.getIcon(arrivalTime, departureTime)
                    }
                ]
            }
        }

        SilicaListView {
            id: tickets

            anchors.top: routeInfoView.bottom
//            anchors.left: parent.left
//            anchors.leftMargin: Theme.horizontalPageMargin
//            anchors.right: parent.right
//            anchors.rightMargin: Theme.horizontalPageMargin
            anchors.bottom: buyButton.top
            spacing: Theme.paddingMedium
            clip: true
            width: parent.width

            model: prices

            delegate: PriceInfoDelegate {
                pricesInfo: model
            }

//            delegate: ListItem {
//                height: Theme.itemSizeMedium
//                Text {
//                    id: seats

//                    font.pixelSize: Theme.fontSizeExtraSmall
//                    color: Theme.secondaryColor
//                    text: qsTr("Seats: ") + seatsCount
//                }
//                Label {
//                    anchors.bottom: parent.bottom

//                    font.pixelSize: Theme.fontSizeExtraSmall
//                    color: Theme.secondaryColor
//                    text: qsTr("Price: ") + price
//                }
//            }
        }

        Button {
            id: buyButton

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Buy")

            onClicked: {
                var url = routeInfo.getBuyUrl(routeData.buyUrl)
                console.log(url)
//                pageStack.push(Qt.resolvedUrl("WebPage.qml"), {pageUrl: url})
            }
        }
    }
}

