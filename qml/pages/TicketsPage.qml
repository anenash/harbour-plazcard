import QtQuick 2.4
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import plazcard.Info 1.0

Page {
    id: page

    property string url

    ConfigurationValue {
        id: suburbanSearch

        key: "/suburbanSearch"
    }

    Component {
        id: ticketDelegate
        TicketDelegate { ticket: value }
    }

    Component {
        id: suburbanTrainDelegate
        SuburbanTrainDelegate { info: value }
    }

    QtObject {
        id: internal

        property bool loadData: true
        property bool noTicketsFound: false

        function getDirection(direction) {
            if (direction === "true") {
                return qsTr("Forth")
            } else if (direction === "false"){
                return qsTr("Back")
            }
        }
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
        ticketsInfo.setSearchType(suburbanSearch.value)
        ticketsInfo.getTickets(url)
    }
    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header

            anchors.top: parent.top
            title: suburbanSearch.value ? qsTr("Suburban train") : qsTr("Railway trip")
        }

        SilicaListView {
            id: ticketsListView

            clip: true
            spacing: Theme.paddingMedium
            width: parent.width
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            model: ticketsModel

            section {
                property: "direction"
                criteria: ViewSection.FullString
                delegate: PageHeader {
                    title: internal.getDirection(section)
                }
            }

            delegate: Component {
                Loader {
                    property variant value: ticketsModel.get(index)
                    sourceComponent: suburbanSearch.value ? suburbanTrainDelegate : ticketDelegate
                }
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
