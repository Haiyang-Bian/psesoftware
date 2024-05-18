import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "qrc:/dndkit/DndComp"
import "qrc:/mainmenu/MainMenu"

Rectangle {
    id: prosessWindow
    visible: true
    width: 1000
    height: 700
    anchors.margins: 2
    border.color: "#DCAAF9"

    property int nodeId: 0
    property int edgeId: 0

    signal close()

    Action {
        id: browseAction
        icon.source: "qrc:/icons/Icons/CodiconBrowser.svg"
        onTriggered: {
            libBro.source = "/system/System/LibBrowser.qml"
            libBro.active = true
        }
    }

    Action {
        id: runAction
        icon.source: "qrc:/icons/Icons/CodiconDebugAlt.svg"
        onTriggered: {
            Controler.generateSimulation(sysWindow.pname, sysWindow.sysname)
            initAndSet.source = "/system/System/InitAndSet.qml"
            initAndSet.active = true
        }
    }

    Action {
        id: saveAction
        icon.source: "qrc:/icons/Icons/CodiconSave.svg"
        onTriggered: {
            
        }
    }

    Action {
        id: setAction
        icon.source: "qrc:/icons/Icons/CarbonSettings.svg"
        onTriggered: {
            initAndSet.source = "qrc:/system/System/InitAndSet.qml"
            initAndSet.active = true
        }
    }

    Action {
        id: checkCharts
        icon.source: "qrc:/icons/Icons/CarbonChartLineSmooth.svg"
        onTriggered: {
            
        }
    }

    Action {
        id: update
        icon.source: "qrc:/icons/Icons/CodiconRefresh.svg"
        onTriggered: {
            Controler.useLocalLibs(sysWindow.pname)
        }
    }

    Action {
        id: close
        icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
        
        onTriggered: {
            prosessWindow.close()
        }
    }

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
                action: browseAction 

                ToolTip {
                    text: "库浏览器"
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
                action: runAction
                
                ToolTip {
                    text: "开始仿真"
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

            ToolButton { 
                action: setAction 
                ToolTip {
                    text: "仿真设置"
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
                action: checkCharts 

                ToolTip {
                    text: "图表"
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
                action: close

                ToolTip {
                    text: "关闭"
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

    property var id: 0
    property var eid: 0

    // 边栏
    Rectangle {
        id: sidebar
        width: 20
        height: parent.height
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
        }
    }

    property var sysDnd: Controler.getDnd(sysWindow.pname, sysWindow.sysname)

    DropComponent {
        id: mainDrop
        anchors {
            top: tools.bottom
            right: parent.right
            bottom: parent.bottom
            left: sidebar.right
        }

        libModels: Controler.linkLibrary()
        dndControler: sysDnd
    }

// 功能区------------------------------------------------------------------------------------------

    Loader {
        id: libBro
        active: false
        anchors.fill: parent
        source: "qrc:/system/System/LibBrowser.qml"

        onLoaded: {
            item.updateLibs.connect(arr=>{
                Controler.selectLibs(arr)
            })
            libBro.item.closing.connect(()=>{
                libBro.source = ""
                libBro.active = false
            })
        }
    }

    Loader {
        id: initAndSet
        active: false
        anchors.fill: parent
        source: ""

        onLoaded: {
            initAndSet.item.closing.connect(()=>{
                initAndSet.source = ""
                initAndSet.active = false
            })
        }
    }
}