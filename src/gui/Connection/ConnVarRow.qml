import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: editDelegate
    height: 50
    property var varIndex: 0
    property bool vselected: false
    
    anchors.margins: 2

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: editDelegate.width / 3
            Layout.preferredHeight: 50
            color: vselected ? "blue" : "white"
            border {
                color: "black"
                width: 2
            }
            Text {
                anchors.centerIn: parent
                text: Name
            }
        }

        Rectangle {
            Layout.preferredWidth: editDelegate.width / 3
            Layout.preferredHeight: 50
            color: vselected ? "blue" : "white"
            border {
                color: "black"
                width: 2
            }
            // 类型下拉框
            ComboBox {
                textRole: "name"
                valueRole: "name"
                anchors.margins: 2
                anchors.fill: parent
                currentIndex: getVarIndex(varIndex)

                model: editWindow.varTypes
                
                onActivated: {
                    if (currentValue !== undefined) {
                        connWindow.typeList.editType({
                            "Type": currentValue
                        }, connList.connId, varIndex)
                    }
                }

                delegate: ItemDelegate {
                    width: editDelegate.width / 3
                    height: 40
                    Text {
                        text: name
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: editDelegate.width / 3
            Layout.preferredHeight: 50
            color: vselected ? "blue" : "white"
            border {
                color: "black"
                width: 2
            }
            
            ComboBox {
                anchors.fill: parent
                anchors.margins: 2
                currentIndex: getConnTypeIndex(varIndex)

                model: ListModel {
                    ListElement{ type:"Equal" }
                    ListElement{ type:"Flow" }
                    ListElement{ type:"Stream" }
                }
                
                onActivated: {
                    if (currentValue !== undefined) {
                        connWindow.typeList.editType({
                            "Connect": currentValue
                        }, connList.connId, varIndex)
                    }
                }

                delegate: ItemDelegate {
                    width: editDelegate.width / 3
                    height: 40
                    Text {
                        text: type
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                    }
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
            text: "删除";
            onTriggered: {
                connList.port.remove(varIndex)
                connWindow.typeList.removeConnectionVar(connList.connId, varIndex)
            }
        }
    }

    // 依据变量序号查询变量类型进而查询其在变量类型表中的位置
    function getVarIndex(vindex) {
        var type = connWindow.typeList.getVarType(connList.connId, vindex, 3)
        var id = editWindow.varTypes.getIdByType(type)
        if (id === -1) {
            return 0
        }
        else {
            return id
        }
    }

    // 依据变量序号查询连接类型
    function getConnTypeIndex(vindex) {
        let type = connWindow.typeList.getVarType(connList.connId, vindex, 8)
        switch (type) {
        case "Equal":
            return 0;
        case "Flow":
            return 1;
        case "Stream":
            return 2
        default:
            return 0
        }
    }
}