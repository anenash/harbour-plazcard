import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: settingsPage

    ConfigurationValue {
        id: useInternalBrowser

        key: "/useInternalBrowser"
    }

    Column {
        id: column

        width: settingsPage.width
        spacing: Theme.paddingSmall
        anchors.horizontalCenter: settingsPage.horizontalCenter
        PageHeader {
            id: pageHeader

            title: qsTr("Settings")
        }
        TextSwitch {
            id: useBrowser

            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            checked: !useInternalBrowser.value
            text: qsTr("Use system browser")

            onCheckedChanged: {
                useInternalBrowser.value = !checked
            }
        }
    }
}
