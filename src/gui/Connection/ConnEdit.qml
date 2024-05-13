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

    property var varTypes: undefined

    Rectangle {
        id: tableHeader
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 50

        Row {
            anchors.fill: parent

            Repeater {
                model: ["变量名称", "变量类型", "连接类型"]

                delegate: Rectangle {
                    height: 50
                    width: (tableHeader.width - 50) / 3

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

            Button {
                icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                width: 50
                height: 50
                onClicked: {
                    connWindow.typeList.createConnectionVar({
                        "Name":  nameInput.text,
                        "Type": "NoUnit",
                        "Connect": "Equal",
                        "Description": descriptionInput.text
                    }, connList.connId)
                    connList.port.append({
                        "Name": name,
                        "Type": "NoUnit",
                        "Description": des
                    })
                }
            }
        }
    }

    ListView {
        id: editList
        anchors {
            top: tableHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        clip: true

        model: connList.port

        delegate: ConnVarRow {
            width: editWindow.width
            varIndex: index
        }
    }

//功能区----------------------------------------------------------------------------------
}