import QtQuick 2.6
import Sailfish.Silica 1.0

import plazcard.Info 1.0


Dialog {

    id: d

    property string stationName
    property string id

    onBackNavigationChanged: {
        serachStations.clearStationsList()
    }

    Component.onCompleted: {
        searchField.focus = true
    }


    Info {
        id: serachStations

        onStationsModelChanged: {
            internal.loadData = false
        }

        onNoStationsFound: {
            internal.loadData = false
            internal.finishSearching = true
        }
    }

    QtObject {
        id: internal

        property bool loadData: false
        property bool finishSearching: false

        function searchStation() {
            var searchText = searchField.text.replace(/ /g, '%20')

            serachStations.getStations(searchText)
            internal.loadData = true
            internal.finishSearching = false
        }
    }

    Timer {
        id: startSearch
        interval: 1500
        repeat: false

        onTriggered: {
            serachStations.clearStationsList()
            internal.searchStation()
        }
    }

//    function getName(iata) {
//        return airportsInfo[iata].name
//    }

    Item {
        id: searchItem

        anchors.fill: parent

        SearchField {
            id: searchField
            anchors.top: parent.top
            width: parent.width
            placeholderText: qsTr('Search stations:')
            focus: true

            onTextChanged: {
                if(searchField.text.length > 2) {
                    startSearch.restart()
                }
            }

            EnterKey.onClicked: {
                if(searchField.text.length > 2) {
                    startSearch.stop()
                    internal.searchStation()
                }
            }
        }
        SilicaListView {
            id: stationsListView

            clip: true
            spacing: Theme.paddingSmall
            width: parent.width
            anchors.top: searchField.bottom
            anchors.bottom: parent.bottom

            model: serachStations.stationsModel

            delegate: ListItem {
                height: Theme.itemSizeExtraSmall
                width: parent.width
                Icon {
                    id: icon

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.highlightColor
                    height: Theme.iconSizeMedium
                    width: Theme.iconSizeMedium
                    source: "image://theme/icon-m-location"
                }
                Label {
                    anchors.left: icon.right
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    text: name
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeSmall
                }

                onClicked: {
                    d.stationName = name
                    d.id = id
                    d.accept()
                }

                Separator {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.bottom: parent.bottom
                    width: parent.width
                }
            }
            VerticalScrollDecorator {flickable: stationsListView}
            ViewPlaceholder {
                enabled: !internal.loadData && internal.finishSearching
                text: qsTr("No stations found")
                hintText: qsTr("Enter a city name")
            }
            BusyIndicator {
                running: internal.loadData
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
            }
        }
    }
}

