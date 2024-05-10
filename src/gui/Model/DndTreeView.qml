import QtQuick
import QtQuick.Controls
import Ai4Energy 1.0

Rectangle {
    id: root
    width: 700
    height: 700
    anchors.margins: 2
    border.width: 2
    border.color: "black"

    signal editModel(var index)
    signal renameModel(var index, string name)

    property var treeModel: undefined

    Component.onCompleted: {
           treeModel.resetItems();
    }

    TreeView {
        id: treeView
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: 300

        anchors.margins: 10
        clip: true

        selectionModel: ItemSelectionModel {}

        model: treeModel


        delegate: Item {
            implicitWidth: padding + label.x + label.implicitWidth + padding
            implicitHeight: label.implicitHeight * 1.5

            readonly property real indentation: 20
            readonly property real padding: 5

            required property TreeView treeView
            required property bool isTreeNode
            required property bool expanded
            required property int hasChildren
            required property int depth
            required property int row
            required property int column
            required property bool current

            property Animation indicatorAnimation: NumberAnimation {
                target: indicator
                property: "rotation"
                from: expanded ? 0 : 90
                to: expanded ? 90 : 0
                duration: 100
                easing.type: Easing.OutQuart
            }
            TableView.onPooled: indicatorAnimation.complete()
            TableView.onReused: if (current) indicatorAnimation.start()
            onExpandedChanged: indicator.rotation = expanded ? 90 : 0

            Rectangle {
                id: background
                anchors.fill: parent
                color: "transparent"

                property int myRow: row
                property string myType: depth > 0 ? type : "DataBase"

                Label {
                    id: indicator
                    x: padding + (depth * indentation)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: isTreeNode && hasChildren
                    text: "▶"
                }

                Label {
                    id: label
                    x: padding + (isTreeNode ? (depth + 1) * indentation : 0)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 3
                    width: parent.width - padding - x
                    clip: true
                    text: name
                }

                TextField {
                    id: labelInput
                    focus: false
                    visible: false
                    x: padding + (isTreeNode ? (depth + 1) * indentation : 0)
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - padding - x
                    clip: true
                    placeholderText: name

                    onAccepted: {
                        treeModel.changeName(treeView.index(row, 0), text)
                        root.renameModel(treeView.index(row, 0), text)
                        label.text = text
                        focus = false
                        visible = false
                        label.visible = true
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton | Qt.LeftButton

                    onSingleTapped: (eventPoint, button) => {
                        if (button === Qt.LeftButton) {
                            let index = treeView.index(row, column)
                            treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                            treeView.toggleExpanded(row)
                        } else {
                            contextMenu.popup(eventPoint.position);
                        }
                    }

                    onDoubleTapped: {
                        let treeIndex = treeView.index(row, column)
                        root.editModel(treeIndex)
                    }
                }

                Drag.dragType: Drag.Automatic
                Drag.supportedActions: Qt.CopyAction
                Drag.hotSpot.x: 5
                Drag.hotSpot.y: 5

                DragHandler {
                    id: dragHandler

                    onActiveChanged: {
                        if (active) {
                            parent.grabToImage(function(result) {
                                parent.Drag.imageSource = result.url
                                parent.Drag.active = true
                            })
                        } else {
                            if (parent.Drag.supportedActions === Qt.CopyAction) {
                                parent.Drag.active = false
                            }
                        }
                        if (expanded)
                            treeView.toggleExpanded(row)
                    }
                }
            }

            Menu {
                id: contextMenu
                MenuItem {
                    text: "新建库";
                    onTriggered: {
                        treeModel.createLib("NewLib")
                    }
                }
                MenuItem {
                    text: "新建模型";
                    onTriggered: {
                        treeModel.createItem(treeView.index(row, column), false, "NewModel")
                    }
                }
                MenuItem {
                    text: "新建筛选器";
                    onTriggered: {
                        treeModel.createItem(treeView.index(row, column), true, "NewFilter")
                    }
                }
                MenuItem {
                    text: "重命名";
                    onTriggered: {
                        label.visible = false
                        labelInput.visible = true
                        labelInput.forceActiveFocus()
                    }
                }
                MenuItem {
                    text: "删除";
                    onTriggered: {
                        treeModel.removeItem(treeView.index(row, column))
                    }
                }
            }

            DropArea {
                id: items
                anchors.fill: parent

                onDropped: drop => {
                    if (drop.source.myType !== "DataBase")
                        treeModel.moveItem(treeView.index(drop.source.myRow, 0), treeView.index(row, 0))
                }
            }
        }
    }
}
