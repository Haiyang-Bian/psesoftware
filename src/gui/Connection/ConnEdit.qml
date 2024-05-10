import QtQuick
import QtQuick.Controls
import Qt.labs.qmlmodels
import QtQuick.Layouts
import Ai4Energy 1.0

Rectangle {
    id: editWindow

    anchors {
        fill: parent
        margins: 2
    }

    property VarModel varTypes: Controler.getVarTypes(connWindow.pname)

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.preferredHeight: 50
            Layout.preferredWidth: editWindow.width

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: ["变量名称", "变量类型", "连接类型"]

                    delegate: Rectangle {
                        Layout.preferredHeight: 50
                        Layout.preferredWidth: parent.width / 3

                        border {
                            color: "black"
                            width: 2
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                        }
                    }
                }
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onSingleTapped: eventPoint => {
                    contextMenu.popup(eventPoint.position)
                }
            }

            Menu {
                id: contextMenu
                MenuItem {
                    text: "新建";
                    onTriggered: {
                        editVarLoader.source = "/connection/Connection/ConnVarInput.qml"
                        editVarLoader.active = true
                    }
                }
            }
        }

        ListView {
            id: editList
            Layout.preferredWidth: editWindow.width
            Layout.fillHeight: true
            clip: true

            model: connList.port

            delegate: ConnVarRow {
                width: editWindow.width
                varIndex: index
            }
        }
    }

//功能区----------------------------------------------------------------------------------

    Loader {
        id: editVarLoader
        active: false
        source: ""
        onLoaded: {
            item.create.connect((name,des)=>{
                createVar(name, des)
                editVarLoader.source = ""
                editVarLoader.active = false
            })
        }
    }

    function createVar(name, des) {
        connList.port.append({
            "Name": name,
            "Description": des
        })
    }
}