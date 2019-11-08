import QtQuick 2.4
import Sailfish.Silica 1.0

import plazcard.Info 1.0

Page {
    id: page

    property variant data: ({})
    property variant prices: ({})

    visible: true

    Component.onCompleted: {
        console.log(page.width, page.height, page.visible)
        console.log(buyButton.width, buyButton.height, buyButton.visible)
        routeInfo.getRoute(data.routeInfo)
    }

    Info {
        id: routeInfo

        onRouteModelChanged: {
            for (var i in routeInfo.routeModel) {
//                console.log(JSON.stringify(routeInfo.routeModel[i].data))
                routeModel.append(routeInfo.routeModel[i].data)
            }
        }
    }

    ListModel {
        id: routeModel
    }

//    SilicaFlickable {
//        anchors.fill: parent

//        PageHeader {
//            id: header

//            anchors.top: parent.top
//            title: qsTr("Information")
//        }

//        SilicaListView {
//            id: routeInfoView

//            anchors.top: header.bottom
//            anchors.left: parent.left
//            anchors.leftMargin: Theme.horizontalPageMargin
//            anchors.right: parent.right
//            anchors.rightMargin: Theme.horizontalPageMargin
//            anchors.bottom: buyButton.top
//            spacing: Theme.paddingMedium
//            height: parent.height * 0.33

//            model: routeModel

//            delegate: Label {
//                text:  name
//            }
//        }

//        SilicaListView {
//            id: tickets

//            anchors.top: routeInfoView.bottom
//            anchors.left: parent.left
//            anchors.leftMargin: Theme.horizontalPageMargin
//            anchors.right: parent.right
//            anchors.rightMargin: Theme.horizontalPageMargin
//            anchors.bottom: buyButton.top
//            spacing: Theme.paddingMedium
//            height: parent.height * 0.33

//            model: prices

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
//        }

        Button {
            id: buyButton

//            anchors.bottom: parent.bottom
//            anchors.bottomMargin: Theme.paddingSmall
//            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Buy")

            onClicked: {
                var url = routeInfo.getBuyUrl(data.buyUrl)
                console.log(url)
//                pageStack.push(Qt.resolvedUrl("WebPage.qml"), {pageUrl: url})
            }
        }
//    }
}
