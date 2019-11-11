import QtQuick 2.4
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import plazcard.Info 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    property variant routeData: ({})
    property variant prices: ({})

    Component.onCompleted: {
        routeInfo.getRoute(routeData.routeInfo)
    }

    ConfigurationValue {
        id: useInternalBrowser

        key: "/useInternalBrowser"

        onValueChanged: {
            internal.useInternalBrowser = value
        }
    }

    QtObject {
        id: internal

        property bool routeSearch: false

        function getDescription(arrival, stay, departure) {
            var result = ""
            if (arrival && arrival !== "") {
                result += "\u23F7 " + arrival
            }
            if (stay && stay !== "") {
                result += " \u2B62 \u23F1 " + stay.replace("&nbsp;м", " мин") + " \u2B62"
            }
            if (departure && departure !== "") {
                result += " \u23F6 " + departure
            }

            return result
        }

        function getIcon(arrival, departure) {
            if (arrival !== "" && departure !== "") {
                return "../images/midStation.svg"
            } else if (arrival !== "") {
                return "../images/stop.svg"
            } else {
                return "../images/start.svg"
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
            anchors.right: parent.right
            height: parent.height * 0.33
            clip: true

            model: routeModel

            delegate: PageHeader {
                id: route

                title: name
                description: internal.getDescription(arrivalTime, stayTime, departureTime)
                extraContent.children: [
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        height: route.height
                        fillMode: Image.PreserveAspectFit
                        source: internal.getIcon(arrivalTime, departureTime)
                    }
                ]
            }

            VerticalScrollDecorator {flickable: routeInfoView}

            BusyIndicator {
                id: routeBusyIndicator

                anchors.centerIn: parent
                running: routeModel.count == 0
                size: BusyIndicatorSize.Large
            }
        }

        SectionHeader {
            id: ticketsSection

            anchors.top: routeInfoView.bottom
            anchors.topMargin: Theme.paddingMedium
            text: qsTr("Tickets")
        }

        SilicaListView {
            id: tickets

            anchors.top: ticketsSection.bottom
            anchors.bottom: buyButton.top
            spacing: Theme.paddingMedium
            clip: true
            width: parent.width

            model: prices

            delegate: PriceInfoDelegate {
                pricesInfo: model
            }
        }

        Button {
            id: buyButton

            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Buy")

            onClicked: {
                var url = routeInfo.getBuyUrl(routeData.buyUrl)
                if (useInternalBrowser.value){
                    pageStack.push(Qt.resolvedUrl("WebPage.qml"), {pageUrl: url})
                } else {
                    console.log("application started", Qt.openUrlExternally(url))
                }
            }
        }
    }
}

