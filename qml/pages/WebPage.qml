import QtQuick 2.4
import Sailfish.Silica 1.0

Page {
    id: root

    property string pageUrl: "https://www.tutu.ru/"

    SilicaWebView {
        id: webView

        anchors.fill: parent

        url: pageUrl
    }
}
