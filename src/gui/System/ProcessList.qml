import QtQuick 
import QtQuick.Controls
import QtQuick.Controls.Material
import Ai4Energy 1.0

Rectangle {
    id: sysWindow
    width: 500
    height: 600
    visible: true

    anchors.margins: 3
    color: "#DCD4F3"
    border.color: "#9D7DF5"
    border.width: 2

    property string pname: ""
    property int modelId: 0
    property string sysname: ""


    SplitView {
        anchors {
            fill: parent
            margins: 2
        }

        orientation: Qt.Horizontal

        Rectangle {
            id: listBlock
            SplitView.minimumWidth: 200
            SplitView.preferredWidth: 250
            height: sysWindow.height

            border.color: "#7EBAF5"
            border.width: 2

            Column {

                anchors.fill: parent
                Rectangle {
                    id: sysListHeader
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: 1
                    }
                    height: 50
                    color: "#C2AFFF"

                    border {
                        width: 1
                        color: "#CF7EF7"
                    }

                    Text {
                        anchors.fill: parent
                        text: "过程列表"
                    }

                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onSingleTapped: eventPoint => {
                            headMenu.popup(eventPoint.position)
                        }
                    }

                    Menu {
                        id: headMenu
                        MenuItem {
                            text: "新建";
                            onTriggered: {
                                loader1.source = "qrc:/system/System/SystemInput.qml"
                                loader1.active = true
                            }
                        }
                        MenuItem {
                            text: "导入";
                            onTriggered: {
                                
                            }
                        }
                    }
                }

                ListView {
                    id: sysList
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: 1
                    }

                    height: parent.height - 50

                    model: systems

                    delegate: mainList
                }
            }
        }

        Rectangle {
            id: systemEditSpace

            SplitView.minimumWidth: 500
            SplitView.maximumWidth: sysWindow.width - 200
            SplitView.fillWidth: true

            Loader {
                id: editorLoader
                anchors.fill: parent
                source: ""
                active: false
                onLoaded: {
                    item.close.connect(()=>{
                        editorLoader.source = ""
                        editorLoader.active = false
                    })
                }
            }
        }
    }

// 功能区-------------------------------------------------------------------------------------------

    ListModel {
        id: systems
    }

    Component.onCompleted: {
        let sys = Controler.getSystems(sysWindow.pname)
        if (sys.length > 0){
            for (let name of sys) {
                systems.append({
                    "name": name
                })
            }
        }
    }

    Component {
        id: mainList
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                margins: 1
            }
            height: 50
            
            Text {
                text: name
            }
            TapHandler {
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                onSingleTapped: (eventPoint, button) => {
                    if (button === Qt.RightButton)
                        contextMenu.popup(eventPoint.position)
                }
                onDoubleTapped: (eventPoint, button) => {
                    if (button === Qt.LeftButton) {
                        sysWindow.modelId = index
                        sysname = name
                        editorLoader.source = "qrc:/system/System/System.qml"
                        editorLoader.active = true
                    }
                }
            }
            Menu {
                id: contextMenu
                MenuItem {
                    text: "删除";
                    onTriggered: {
                        systems.remove(index)
                    }
                }
            }
        }
    }

    Loader {
        id: loader1
        active: false // 初始时不激活
        anchors.fill: parent
        source: "" // 设置子窗口的源文件
        onLoaded: {
            loader1.item.confirmCreation.connect(name => {
                sysWindow.sysname = name
                Controler.createSystem(sysWindow.pname, name)
                systems.append({
                    "name": name
                })
                modelCreate()
                loader1.source = ""
                loader1.active = false
            })
        }
    }

    function editorClose() {
        editorLoader.source = ""
        editorLoader.active = false
    }
    function modelCreate() {
        editorLoader.source = "/system/System/System.qml"
        editorLoader.active = true
    }
}

