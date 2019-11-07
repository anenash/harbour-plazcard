import QtQuick 2.4
import Sailfish.Silica 1.0

import plazcard.Info 1.0

Page {
    id: page

    property string url

    QtObject {
        id: internal

        property bool loadData: true
        property bool noTicketsFound: false
    }

    Info {
        id: ticketsInfo

        onTicketsModelChanged: {
            internal.loadData = false
            for(var i in ticketsInfo.ticketsModel) {
//                console.log(JSON.stringify(ticketsInfo.ticketsModel[i].data))
                ticketsModel.append(ticketsInfo.ticketsModel[i].data)
            }
        }

        onNoTicketsFound: {
            internal.loadData = false
            internal.noTicketsFound = true
        }
    }
    ListModel {
        id: ticketsModel
    }

    Component.onCompleted: {
        ticketsInfo.getTickets(url)
    }
    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header

            anchors.top: parent.top
            title: qsTr("Railway trip")
        }

        SilicaListView {
            id: ticketsListView

            clip: true
            spacing: Theme.paddingMedium
            width: parent.width
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            model: ticketsModel //ticketsInfo.ticketsModel

    //        section {
    //            property: "direction"
    //            delegate: SectionHeader {
    //                text: "Railway trip111"//model.direction /*?qsTr("Forth"):qsTr("Back")*/
    //            }
    //        }

            section {
                property: "direction"
                criteria: ViewSection.FullString
                delegate: PageHeader {
                    title: section?qsTr("Forth"):qsTr("Back")
                }
            }

            delegate: TicketDelegate {
                ticket: ticketsModel.get(index)//model.data
            }

            VerticalScrollDecorator {flickable: ticketsListView}


            BusyIndicator {
                running: internal.loadData
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
            }

            ViewPlaceholder {
                enabled: !internal.loadData && ticketsModel.count === 0
                text: qsTr("No tickets found")
                hintText: qsTr("Please, change the search request")
            }
        }
    }
}
