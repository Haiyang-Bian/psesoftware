import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qrc:/mainmenu/MainMenu"
import "qrc:/dndkit/DndComp"

Rectangle {
	id: subSystemEditor

    anchors.margins: 2
    border.color: "black"
    border.width: 2

    ToolBar {
        id: tools
        anchors.top: parent.top
        anchors.left: parent.left
        contentHeight: toolBarRow.height
        width: parent.width
        height: 40

        RowLayout {
            id: toolBarRow
            spacing: 10
            
            ToolButton { 
                action: saveAction 
                ToolTip {
                    text: "保存"
                    visible: parent.hovered
                    background: Rectangle {
                        border {
                            color: "black"
                            width: 1
                        }
                        radius: 5
                    }
                }
            }

            ToolButton { 
                action: update 
                ToolTip {
                    text: "刷新"
                    visible: parent.hovered
                    background: Rectangle {
                        border {
                            color: "black"
                            width: 1
                        }
                        radius: 5
                    }
                }
            }
        }
    }

    Rectangle {
        id: sidebar
        width: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: tools.bottom
        color: "#F9F0FD"
        clip: true

        property bool isStored: true

        Button {
            id: ex
            anchors.right: parent.right
            anchors.top: parent.top

            width: 20
            height: 20
            font.pointSize: 10
            font.bold: true

            IconImage {
                id: exIcon
                anchors.fill: parent
                source: "qrc:/icons/Icons/CodiconChevronRight.svg"

                transform: Rotation {
                    id: rotation
                    origin.x: exIcon.width / 2
                    origin.y: exIcon.height / 2
                    angle: 0
                }
            }

            onClicked: {
                if (!sidebar.isStored)
                {
                    rotation.angle -= 90
                    sidebar.isStored = true
                    sidebar.width = 20
                } else {
                    rotation.angle += 90
                    sidebar.isStored = false
                    sidebar.width = 200
                }
            }
        }

        LibTree {
            id: libList
            anchors {
               left: sidebar.left
               top: sidebar.top
               bottom: sidebar.bottom
            }
            width: !sidebar.isStored ? sidebar.width - 20 : 0

            treeModel: Controler.linkLibrary()

            dnd: modelWindow.models.editSubSystem(modelBuilder.model)
        }
    }

	DropComponent {
		id: workSpace
		anchors {
            top: tools.bottom
            right: parent.right
            bottom: parent.bottom
            left: sidebar.right
        }
        dndControler: modelWindow.models.editSubSystem(modelBuilder.model)
	}

// 功能区--------------------------------------------------------------------------------------------
    
    Action {
        id: update
        icon.source: "qrc:/icons/Icons/CodiconRefresh.svg"
        onTriggered: {
            Controler.useLocalLibs(modelBuilder.pname)
        }
    }

    Action {
        id: saveAction
        icon.source: "qrc:/icons/Icons/CodiconSave.svg"
        onTriggered: {
            
        }
    }

	Component.onCompleted: {
        setPorts()
    }

    ObjectModel {
        id: ports
    }

    function hasPort(name) {
        for (let i = 0; i < ports.count; ++i) {
            if (name === ports.get(i).setname){
                return i + 1
            }
        }
        return false
    }

    function setPorts() {
        let arr = modelWindow.models.getData(modelBuilder.model, "Ports")
        for (let i = 0;i < arr.length; ++i){
            let comp = Qt.createComponent("qrc:/dndkit/DndComp/DragComponent.qml")
            if (comp.status !== Component.Ready){
                console.debug(comp.errorString())
            }
            let index = hasPort(arr[i].Name)
            if (!index) {
                let obj = comp.createObject(workSpace,
                    {
                        "dnd": workSpace.dndControler,
                        "setname": arr[i].Name,
                        "x": 20 + 100 * i,
                        "y": 20,
                        "supportedActions": Qt.MoveAction,
                        "dragType": Drag.Internal,
                        "isDropped": true,
                        "isPort": true,
                        "hdata": [arr[i]],
                        "width": 80,
                        "height": 80
                    }
                )
                ports.append(obj)
            } else {
                let obj = comp.createObject(workSpace,
                    {
                        "setname": arr[i].Name,
                        "x": ports.get(index - 1).x,
                        "y": ports.get(index - 1).y,
                        "supportedActions": Qt.MoveAction,
                        "dragType": Drag.Internal,
                        "isDropped": true,
                        "isPort": true,
                        "hdata": [arr[i]],
                        "width": 80,
                        "height": 80
                    }
                )
                ports.remove(index - 1)
                ports.insert(obj, index - 1)
            }
        }
    }
}
