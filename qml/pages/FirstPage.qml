import QtQuick 2.4
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import plazcard.Info 1.0

Page {
    id: page

    ConfigurationValue {
        id: useInternalBrowser

        key: "/useInternalBrowser"
        defaultValue: false
    }

    QtObject {
        id: internal

        property string origin
        property string originText
        property string destination
        property string destinationText

        property string departureDateValue: qsTr("Select")
        property date departureSelectedDate: new Date()
        property bool departureDateValueIsSet: false

        property string returnDateValue: qsTr("Select")
        property date returnSelectedDate: new Date()
        property bool returnDateValueIsSet: false
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Portrait

    Info {
        id: serachTickets
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Railway tickets")
            }

            ValueButton {
                id: originSelector

                label: qsTr("From:")
                value: !internal.originText?qsTr('Select'):internal.originText
                width: parent.width

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SearchStationDialog.qml"))

                    dialog.accepted.connect(function() {
                        internal.originText = dialog.stationName
                        internal.origin = dialog.id
                    })
                }
            }
            ValueButton {
                id: destinationSelector

                label: qsTr("To:")
                value: !internal.destination?qsTr('Select'):internal.destinationText
                width: parent.width

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("SearchStationDialog.qml"))

                    dialog.accepted.connect(function() {
                        internal.destinationText = dialog.stationName
                        internal.destination = dialog.id
                    })
                }
            }
            ValueButton {
                id: departureDate

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: internal.departureSelectedDate
                                 })

                    dialog.accepted.connect(function() {
                        var currDate = new Date()
                        if (currDate <= dialog.date) {
                            internal.departureDateValue = dialog.day + "." + dialog.month + "." + dialog.year
                            internal.departureSelectedDate = dialog.date
                            internal.departureDateValueIsSet = true
                        }

                        //Depart date can not be from past
                    })
                }

                label: qsTr("Departure date:")
                value: internal.departureDateValue
                width: parent.width
                onClicked: openDateDialog()
            }
            TextSwitch {
                id: roundTrip

                checked: false
                text: qsTr("Round trip")
            }

            ValueButton {
                id: returnDateDate

                visible: roundTrip.checked

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: internal.returnSelectedDate
                                 })

                    dialog.accepted.connect(function() {
                        var currDate = new Date()
                        if (currDate <= dialog.date && internal.departureSelectedDate <= dialog.date) {
                            internal.returnDateValue = dialog.day + "." + dialog.month + "." + dialog.year
                            internal.returnSelectedDate = dialog.date
                            internal.returnDateValueIsSet = true
                        }
                        //Depart date can not be from past
                    })
                }

                label: qsTr("Return date:")
                value: internal.returnDateValue
                width: parent.width
                onClicked: openDateDialog()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Search")
                enabled: internal.origin && internal.destination && internal.departureDateValueIsSet

                onClicked: {
                    var firstDate = internal.departureDateValue.replace(/ /g, '%20')
                    var secondDate = internal.returnDateValue.replace(/ /g, '%20')
                    var url = "https://www.tutu.ru/poezda/rasp_d.php?nnst1=" + internal.origin +"&nnst2=" + internal.destination + "&date=" + firstDate
                    if (roundTrip.checked) {
                        url += "&date_second=" + secondDate
                    }

                    main.searchString = internal.originText + " - " + internal.destinationText
                    pageStack.push(Qt.resolvedUrl("TicketsPage.qml"), {"url": url})
                }
            }
        }
    }
}
