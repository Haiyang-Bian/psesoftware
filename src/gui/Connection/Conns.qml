import QtQuick 
import QtQuick.Controls
// 似乎导入这个库就不会有改属性的报错了
import QtQuick.Controls.Material
import QtQuick.Layouts
import Ai4Energy 1.0


Rectangle {
    id: connWindow
    
    width: 700
    height: 500
    visible: true

    property string pname: ""
    property ConnModel typeList: undefined;

    Connections {
        target: typeList
        function onUpdateList() {
            connections.clear()
            loadTypes()
        }
    }

    RowLayout {
        anchors.fill: parent

        Rectangle {
            Layout.preferredWidth: connWindow.width * 0.2
            Layout.preferredHeight: connWindow.height
            Layout.rightMargin: 3
            Layout.leftMargin: 3
            Layout.topMargin: 3
            Layout.bottomMargin: 3

            border.color: "black"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    id: tableHeader
                    Layout.preferredWidth: connWindow.width * 0.2
                    Layout.preferredHeight: 50

                    border.color: "black"
                    border.width: 2
                    color: "#DDDDDE"
              
                    Text {
                        anchors.centerIn: parent
                        text: "连接类型名称"
                    }

                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onSingleTapped: eventPoint => {
                            contextMenu.popup(eventPoint.position)
                        }
                    }

                    Menu {
                        id: contextMenu

                        Repeater {
                            model: ["新建", "导入标准接口", "上传接口(内部使用)"]
                        
                            delegate: MenuItem {
                                text: modelData
                                
                                onTriggered: {
                                    buttonEvents(index)
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: connList

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 5
                    clip: true

                    property var port: undefined
                    property var connId: 0

                    model: connections

                    delegate: mainList
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: connWindow.width * 0.76
            Layout.preferredHeight: connWindow.height
            Layout.rightMargin: 3
            Layout.leftMargin: 3
            Layout.topMargin: 3
            Layout.bottomMargin: 3

            border.color: "black"
            border.width: 2

            Loader {
                id: connLoader
                anchors.fill: parent
                source: ""
                active: false
            }
        }
    }
//以下为功能区(不显示)------------------------------------------------------------------------------

    ListModel {
        id: connections
    }

    Component {
        id: mainList

        Rectangle {
            width: connWindow.width * 0.2
            height: 50
            
            border.color: "black"
            border.width: 2

            property bool vselected: false
            property int pIndex: index

            color: vselected ? "blue" : "white"

            Text {
                anchors {
                    fill: parent
                    leftMargin: 5
                    topMargin: 5
                }
                text: Type
            }

            TapHandler {
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                onSingleTapped: (eventPoint, button) => {
                    if (button === Qt.RightButton)
                        contextMenu.popup(eventPoint.position)
                }

                onDoubleTapped: (eventPoint, button) => {
                    if (button === Qt.LeftButton) {
                        connList.port = Variables
                        connList.connId = index
                        connLoader.source = "/connection/Connection/ConnEdit.qml"
                        connLoader.active = true
                    }
                }
            }

            Menu {
                id: contextMenu

                Repeater {
                    model: ["删除", "重命名"]
                
                    delegate: MenuItem {
                        text: modelData
                        
                        onTriggered: {
                            menuEvents(index, pIndex)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        loadTypes()
    }

    Loader {
        id: inputLoader
        anchors.fill: parent
        source: ""
        active: false

        onLoaded: {
            item.createConn.connect(name => {
                connections.append({
                    "Type": name,
                    "Variables": []
                })
                inputLoader.source = ""
                inputLoader.active = false
            })
        }
    }

    function loadTypes(){
        var arr = typeList.getTypes()
        if (arr.length !== 0) {
            arr.forEach(obj => {
                connections.append({
                    "Type": obj.Type,
                    "Variables": obj.Variables
                })
            })
        }
    }

    function buttonEvents(type) {
        switch(type){
        case 0:
            inputLoader.source = "/connection/Connection/ConnInput.qml"
            inputLoader.active = true
            break;
        case 1:
            typeList.loadConnsFromDB(Controler.db, ["ElectricalStandardLibrary"])
            break;
        case 3:
            typeList.insertDB(Controler.db, "PhotovoltaicElectrolysisHydrogenStorageStandardLibrary")
            break;
        }
    }

    function menuEvents(type, item){
        switch(type){
        case 0:
            connWindow.typeList.removeType(item)
            connections.remove(item)
            break;
        }
    }
}
