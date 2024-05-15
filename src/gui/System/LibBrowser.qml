import QtQuick 2.3
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    id: libBrowser
    title: "库浏览器"
    visible: true
    width: 400
    height: 400

    signal updateLibs(var arr)

    Rectangle {
        id: liblist
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            margins: 2
        }
        width: parent.width * 0.7
        color: "#f0f0f0" 
        border.color: "black" 
        border.width: 1
        radius: 5 

        ScrollView {
            anchors.fill: parent
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ListView {
                anchors.fill: parent
                anchors.margins: 2
                flickableDirection: Flickable.VerticalFlick

                model: libs
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    Row {
                        anchors.fill: parent
                        CheckBox {
                            id: checkbox
                            width: 20
                            enabled: model.enabled
                            checked: model.enabled

                            onCheckedChanged: {
                                model.selected = this.checked
                            }
                        }
                        Label {
                            text: model.name
                            color: model.enabled ? "black" : "grey"
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            left: liblist.right
        }

        Button {
            text: "确认"
            onClicked: {
                var arr = []
                for (var i = 0; i < libs.count; ++i) {
                    var item = libs.get(i);
                    if (item.enabled && item.selected) {
                        arr.push(item.name)
                    }
                }   
                libBrowser.updateLibs(arr)
                libBrowser.close()
            }
        }
        Button {
            text: "取消"
            onClicked: {
                libBrowser.close()
            }
        }
    }

// 功能区-----------------------------------------------------------------------------
    ListModel {
        id: libs
        ListElement { name: "Electrical"; enabled: true; selected: false }
        ListElement { name: "PhotovoltaicElectrolysisHydrogenStorage"; enabled: true; selected: false }
        ListElement { name: "Thermal"; enabled: false; selected: false }
        ListElement { name: "Fluid"; enabled: false; selected: false }
    }
}