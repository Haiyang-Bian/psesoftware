import QtQuick 
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Ai4Energy 1.0

Rectangle {
    id: modelWindow
    width: 500
    height: 600
    visible: true
    anchors {
        leftMargin: 3
        rightMargin: 3
        topMargin: 3
        bottomMargin: 3
    }
    border.color: "black"
    border.width: 2
    color: "#94DDE2"

    property string pname: ""
    property var models: undefined
    property int modelId: 0
        

    SplitView {
        anchors {
            fill: parent
            leftMargin: 3
            rightMargin: 3
            topMargin: 3
            bottomMargin: 3
        }

        orientation: Qt.Horizontal

        Rectangle {
            id: modelListSpace
            SplitView.minimumWidth: 200
            SplitView.preferredWidth: 250
            height: modelWindow.height
            color: "#DCD2F7"
            border.color: "black"
            border.width: 2

            Rectangle {
                id: tableHeader
                anchors {
                    left: modelListSpace.left
                    right: modelListSpace.right
                    top: modelListSpace.top
                }
                height: 50

                Row {
                    anchors.fill: parent
                    
                    Repeater {
                        model: ["模型名称"]
                    
                        delegate: Rectangle {
                            width: tableHeader.width
                            height: 50
                            color: "#85B6EF"
                            border.color: "black"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                            }
                        }
                    }
                }
            }

            DndTreeView {
                id: modelTree

                anchors {
                    left: parent.left
                    right: parent.right
                    top: tableHeader.bottom
                    bottom: parent.bottom
                }
                
                treeModel: models
            }
        }

        Rectangle {
            id: modelEditSpace

            SplitView.minimumWidth: 500
            SplitView.maximumWidth: modelWindow.width - 200
            SplitView.fillWidth: true

            Row {
                id: navigationBar
                anchors {
                    right: parent.right
                    left: parent.left
                    top: parent.top
                }

                height: 50

                Repeater {
                    model: headers

                    delegate: ToolBar { 
                        anchors { 
                                top: parent.top
                                bottom: parent.bottom
                            }
                        width: Math.min(300, modelEditSpace.width / headers.count)

                        Row {
                            anchors.fill: parent

                            ToolButton {
                                width: parent.width - 50
                                text: title
                                onClicked: {
                                    modelWindows.currentIndex = index + 1
                                }
                            }

                            ToolButton {
                                width: 50
                                property int pageIndex: index + 1
                                action: closeAction
                            }
                        }
                    }
                }
            }

            StackLayout {
                id: modelWindows
                anchors {
                    top: navigationBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                Repeater {
                    model: pages
                }
            }
        }
    }


// 功能区-------------------------------------------------------------------------------------------
    ListModel {
        id: headers
    }
    
    ObjectModel{
        id: pages
    }

    Action {
        id: closeAction
        icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
        onTriggered: source => {
            let index = source.pageIndex
            headers.remove(index - 1)
            if (index === modelWindows.currentIndex) {
                pages.remove(index - 1)
                modelWindows.currentIndex = index - 1
            } else {
                pages.remove(index - 1)
            }
        }
    }

    Connections {
        target: modelTree

        function onEditModel(index) {
            let name = models.getName(index)
            let i = isPageExist(name)
            if (i > -1)
                modelWindows.currentIndex = i + 1
            else {
                var win = Qt.createComponent("qrc:/model/Model/Model.qml")
                if (win.status !== Component.Ready){
                    console.debug(win.errorString())
                }
                var m = win.createObject(modelEditSpace,
                    {
                        "width": modelEditSpace.width,
                        "height": modelEditSpace.height,
                        "model": index,
                        "pname": pname
                    }
                )
                headers.append({
                    "title": name,
                    "name": name,
                })
                pages.append(m)
                modelWindows.currentIndex = pages.count - 1
            }
        }
        function onRenameModel(index, name) {
            models.rename(index, name)
        }
    }

    function isPageExist(name) {
        for (let i = 0; i < headers.count; ++i) {
            let p = headers.get(i)
            if (p.name === name)
                return i
        }
        return -1
    }
}