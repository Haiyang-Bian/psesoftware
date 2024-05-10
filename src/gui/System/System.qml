import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "qrc:/dndkit/DndComp"

Rectangle {
    id: prosessWindow
    visible: true
    width: 1000
    height: 700
    anchors.margins: 2
    border.color: "#DCAAF9"

    property int nodeId: 0
    property int edgeId: 0

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
        icon.source: "qrc:/icons/Icons/CodiconDebugAlt.svg" // 请替换为适当的图标名称或路径
        onTriggered: {
            Controler.generateSimulation(sysWindow.pname, sysWindow.sysname)
            initAndSet.source = "/system/System/InitAndSet.qml"
            initAndSet.active = true
        }
    }

    Action {
        id: saveAction
        icon.source: "qrc:/icons/Icons/CodiconSave.svg" // 请替换为适当的图标名称或路径
        onTriggered: {
            console.log("保存被点击")
            // 保存动作的逻辑
        }
    }

    Action {
        id: setAction
        icon.source: "qrc:/icons/Icons/CarbonSettings.svg"
        onTriggered: {
            initAndSet.source = "/system/System/InitAndSet.qml"
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
        icon.source: "qrc:/icons/Icons/CodiconRefresh.svg" // 请替换为适当的图标名称或路径
        onTriggered: {
           var libs = Controler.loadLibs()
           if (libs.length != 0) {
                libs.forEach(lib => {
                    var models = []
                    lib.Models.forEach(model => {
                        models.push({
                            "Type": model.Type,
                            "Icon": model.Icon,
                            "Handlers": model.Handlers,
                            "Paras": model.Paras,
                            //"Des": model.des
                        })
                    })
                    compList.append({
                        "LibName": lib.Name,
                        "Models": models
                    })
                })
           }
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
            ToolButton { action: browseAction }
            ToolButton { action: runAction }
            ToolButton { action: saveAction }
            ToolButton { action: update }
            ToolButton { action: setAction }
            ToolButton { action: checkCharts }
        }
    }

    // 应用程序的其他内容...
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
        clip: true // 确保内容不会超出边栏区域

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
                    angle: 0 // 初始角度
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

        ListView {
            id: libList
            anchors {
               left: sidebar.left
               top: sidebar.top
               bottom: sidebar.bottom
            }
            width: sidebar.width - 20

            model: compList

            delegate: libsDele
       }
    }


    DropComponent {
        id: mainDrop
        anchors {
            top: tools.bottom
            right: parent.right
            bottom: parent.bottom
            left: sidebar.right
        }

        dndControler: Controler.getDnd(sysWindow.pname, sysWindow.sysname)
    }

// 功能区------------------------------------------------------------------------------------------

    ListModel {
        id: compList
    }

    Loader {
        id: libBro
        active: false
        anchors.fill: parent
        source: "/system/System/LibBrowser.qml"

        onLoaded: {
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

    Component {
        id: libsDele

        Rectangle {
            id: module
            width: sidebar.width - 20
            height: 50
            border.color: "lightgrey"
            visible: !sidebar.isStored

            property bool isExpanded: false

            Column {
                Row {
                    spacing: 10

                    IconImage {
                        id: icon
                        source: "qrc:/icons/Icons/CodiconChevronRight.svg"

                        transform: Rotation {
                            id: rotation1
                            origin.x: icon.width / 2
                            origin.y: icon.height / 2
                            angle: 0 // 初始角度
                        }
                    }

                    Text {
                        width: sidebar.width - 70
                        height: 50
                        text: LibName
                        wrapMode: Text.WrapAnywhere
                    }
                }

                 // 边栏内容
                GridView {
                    id: son
                    visible: !sidebar.isStored
                    width: sidebar.width - 20
                    cellWidth: 80 // 设置每个单元格的宽度为视图宽度的一半
                    cellHeight: 80 // 您可以根据需要设置单元格的高度
                    clip: true
                    z: 1
                    
                    model: Models
                    
                    delegate: Loader {
                        width: 80;
                        height: module.isExpanded ? 80 : 0

                        source: "qrc:/dndkit/DndComp/DragComponent.qml"

                        onLoaded: {
                            item.paras = Paras
                            item.compType = Type
                            item.image = Icon
                            item.hdata = Handlers
                        }
                    }
                }
            }

            TapHandler {

                onDoubleTapped: {
                    if (!module.isExpanded) {
                        rotation1.angle += 90
                        module.isExpanded = true
                        module.height = 50 + Math.ceil(Models.rowCount() / 2) * 80
                        son.height = Math.ceil(Models.rowCount() / 2) * 80
                    } else {
                        rotation1.angle -= 90
                        module.isExpanded = false
                        module.height = 50
                        son.height = 0
                    }
                }
            }
        }
    }
}