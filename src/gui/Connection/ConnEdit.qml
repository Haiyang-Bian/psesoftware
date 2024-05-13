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
                    let data = {
                        "Name":  "NewVar" + varList.count,
                        "Type": "NoUnit",
                        "ConnectType": "Equal",
                        "Description": "新的变量"
                    }
                    connWindow.typeList.editPortVar(connList.type, data)
                    varList.append(data)
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

        model: varList

        delegate: ConnVarRow {

            onRename: name => {
                connWindow.typeList.renameVar(connList.type, Name, name)
                Name = name
            }

            onEdit: (type, data) => {
                console.log("youbingba")
                let r = {}
                switch(type){
                case 0:
                    r = { "Name": Name }
                    varList.remove(index)
                    break
                case 1:
                    Type = data
                    r = { "Name": Name, "Type": data }
                    break
                case 2: 
                    ConnectType = data
                    r = { "Name": Name, "ConnectType": data }
                    break
                }
                connWindow.typeList.editPortVar(connList.type, r)
            }
        }
    }

//功能区----------------------------------------------------------------------------------

    ListModel {
        id: varList
    }
}