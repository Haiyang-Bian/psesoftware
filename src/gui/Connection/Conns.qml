import QtQuick 
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Ai4Energy 1.0


Rectangle {
    id: connWindow
    
    width: 700
    height: 500
    visible: true

    property string pname: ""
    property var typeList: undefined

    Connections {
        target: typeList
        function onUpdateList() {
            connections.clear()
            loadTypes()
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 3
        }
        width: connWindow.width * 0.2
        border.color: "black"
        border.width: 2

        Row {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 50

            Rectangle {
                id: tableHeader
                height: 50
                width: parent.width - 50
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
                        model: ["导入标准接口", "上传接口(内部使用)"]
                    
                        delegate: MenuItem {
                            text: modelData
                            
                            onTriggered: {
                                buttonEvents(index)
                            }
                        }
                    }
                }
            }

            Button {
                icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                width: 50
                height: 50
                onClicked: {
                    typeList.appendType({
                        "Type": "NewConnect" + connList.count,
                        "Description": "新的接口类型"
                    })
                    connections.append({
                        "Type": "NewConnect" + connList.count,
                        "Variables": []
                    })
                }
            }
        }

        ListView {
            id: connList
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: parent.height - 50
            
            spacing: 5
            clip: true

            property var port: undefined
            property var connId: 0

            model: connections

            delegate: mainList
        }
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 3
        }
        width: connWindow.width * 0.8
        border.color: "black"
        border.width: 2

        Loader {
            id: connLoader
            anchors.fill: parent
            source: ""
            active: false

            onLoaded: {
                item.varTypes = Controler.getVarTypes(connWindow.pname)
            }
        }
    }
//以下为功能区(不显示)------------------------------------------------------------------------------

    ListModel {
        id: connections
    }

    Component {
        id: mainList

        Row {

            Rectangle {
                width: connWindow.width * 0.2 - 50
                height: 50
                
                border.color: "black"
                border.width: 2

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
            typeList.loadConnsFromDB()
            break;
        case 1:
            typeList.insertDB()
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
