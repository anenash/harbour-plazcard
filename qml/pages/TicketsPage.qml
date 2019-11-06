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
        }

        onNoTicketsFound: {
            internal.loadData = false
            internal.noTicketsFound = true
        }
    }

    Component.onCompleted: {
        ticketsInfo.getTickets(url)
    }

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
        model: ticketsInfo.ticketsModel

        section {
            property: 'direction'
            delegate: SectionHeader {
                text: model.data.direction?qsTr("Forth"):qsTr("Back")
            }
        }

        delegate: TicketDelegate {
            ticket: model.data
        }

        VerticalScrollDecorator {flickable: ticketsListView}


        BusyIndicator {
            running: internal.loadData
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
        }

        ViewPlaceholder {
            enabled: internal.noTicketsFound
            text: qsTr("No tickets found")
            hintText: qsTr("Please, change the search request")
        }
    }
}
