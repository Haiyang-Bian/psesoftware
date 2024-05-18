import QtQuick
import QtQuick.Controls
import Ai4Energy 1.0

Rectangle {
    id: dragItem

    width: 80
    height: 80
    x: 0
    y: 0
    z: 100

    border {
        color: "black"
        width: 2
    }

    property DndControler dnd: undefined
    property var dragType: Drag.Automatic
    property var supportedActions: Qt.CopyAction
    property var image: ""
    property string setname: ""
    property bool isDropped: false
    property bool isPort: false
    property var hdata: []
    property string compType: ""
    property var paras: []
    property var type: "Component"
    property bool lock: false
    property bool isCustom: false

    color: "yellow"

    Drag.active: dragHandler.active
    Drag.dragType: dragType
    Drag.supportedActions: supportedActions
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    Image {
        enabled: !isPort
        anchors.fill: parent
        anchors.margins: 2
        source: image
    }

    Text {
        enabled: isPort
        text: setname
        anchors.fill: parent
        anchors.margins: 2
    }

    Repeater {
        model: hdata
        delegate: handlerDelegate
    }

    DragHandler {
        id: dragHandler
        enabled: !dragItem.lock
        onActiveChanged: {
            if (active) {
                parent.grabToImage(function(result) {
                    parent.Drag.imageSource = result.url
                })
            } else {
                if (parent.Drag.supportedActions === Qt.CopyAction) {
                    dragItem.x = 0;
                    dragItem.y = 0;
                }else{
                    dragItem.x -= dragItem.x % 20
                    dragItem.y -= dragItem.y % 20
                    dnd.moveNodeEnd(dragItem.setname, dragItem.x, dragItem.y)
                }
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onDoubleTapped: (eventPoint, button) => {
            if (button === Qt.LeftButton) {
                drawer.open()
            }
        }
        onSingleTapped: (eventPoint, button) => {
            if (button === Qt.RightButton) {
                contextMenu.popup(eventPoint.position);
            }
        }
    }

    Resizer {
        id: rsizer
        anchors.fill: parent
        realParent: dragItem

        onSizeChanged: {
            dnd.resizeNode(dragItem.setname, dragItem.x, dragItem.y, dragItem.width, dragItem.height)
        }
    }

    Drawer {
        id: drawer
        width: 240
        height: parent.height
        edge: Qt.RightEdge
        interactive: true

        Rectangle {
            id: die
            anchors.fill: parent

            DataEditor {
                name: dragItem.setname
                paraList: dragItem.paras
                onEditData: data => {
                    dnd.setNode(dragItem.setname, data)
                }
            }
        }
    }

    states: State {
        when: dragHandler.active
        AnchorChanges {
            target: dragItem
            anchors {
                verticalCenter: undefined
                horizontalCenter: undefined
            }
        }
    }
// 功能区---------------------------------------------------------------------------------  

    Menu {
        id: contextMenu
        MenuItem { 
            text: "删除"; 
            onTriggered: { 
                dnd.removeNode(dragItem.setname)
                dragItem.destroy()
            } 
        }
        MenuItem { text: "复制"; onTriggered: { /* 处理选项2 */ } }
        MenuItem { text: "粘贴"; onTriggered: { /* 处理选项3 */ } }
        MenuItem { text: "剪切"; onTriggered: { /* 处理选项3 */ } }
        MenuItem { text: "顺时针旋转90°"; onTriggered: { /* 处理选项3 */ } }
        MenuItem { text: "逆时针旋转90°"; onTriggered: { /* 处理选项3 */ } }
        MenuItem { 
            text: !dragItem.lock ? "锁定" : "解锁"
            onTriggered: { 
                dragItem.lock = !dragItem.lock
            } 
        }
    }

    Component {
        id: handlerDelegate        

        Handle {
            dnd: dragItem.dnd
            hname: modelData.Name
            visible: isDropped

            Component.onCompleted: {
                let t = Number(modelData.Position)
                if (isPort){
                    t += 2
                    if (t > 4)
                        t -= 4
                }
                switch(t) {
                case 1:
                    anchors.bottom = dragItem.top
                    anchors.bottomMargin = -height / 2
                    anchors.left = dragItem.left
                    anchors.leftMargin = modelData.Offset - width / 2
                    break
                case 2:
                    anchors.left = dragItem.right
                    anchors.leftMargin = -width / 2
                    anchors.top = dragItem.top
                    anchors.topMargin = modelData.Offset - height / 2
                    break
                case 3:
                    anchors.bottom = dragItem.bottom
                    anchors.bottomMargin = -height / 2
                    anchors.left = dragItem.left
                    anchors.leftMargin = modelData.Offset - width / 2
                    break
                case 4:
                    anchors.right = dragItem.left
                    anchors.rightMargin = -width / 2
                    anchors.top = dragItem.top
                    anchors.topMargin = modelData.Offset - height / 2
                    break
                }
            }
        }
    }
}
