import QtQuick
import QtQuick.Controls
import Ai4Energy 1.0

Rectangle {
    id: libTree
    visible: true

    
    property var treeModel: undefined

    TreeView {
        id: treeView
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        selectionModel: ItemSelectionModel {}

        model: treeModel


        delegate: Item {
            id: layer
            implicitWidth: parent.width
            implicitHeight: Math.ceil(models.length / 2) * 100 + 50

            readonly property real indentation: 20
            readonly property real padding: 5

            // Assigned to by TreeView:
            required property TreeView treeView
            required property bool isTreeNode
            required property bool expanded
            required property int hasChildren
            required property int depth
            required property int row
            required property int column
            required property bool current

            // Rotate indicator when expanded by the user
            // (requires TreeView to have a selectionModel)
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
            }

            Label {
                id: indicator
                x: padding + (depth * indentation)
                anchors.verticalCenter: parent.verticalCenter
                visible: isTreeNode && hasChildren
                text: "▶"

                TapHandler {
                    onSingleTapped: {
                        let index = treeView.index(row, column)
                        treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                        treeView.toggleExpanded(row)
                    }
                }
            }

            Label {
                id: label
                x: padding + (isTreeNode ? (depth + 1) * indentation : 0)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - padding - x
                clip: true
                text: name

                TapHandler {
                    onDoubleTapped: {
                        let index = treeView.index(row, column)
                        treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                        treeView.toggleExpanded(row)
                    }
                }
            }

            GridView {
                id: modelsView
                visible: type
                width: type ? parent.width : 0

                cellWidth: 80 
                cellHeight: 80 

                clip: true
                z: 1
                
                model: models
                
                delegate: Loader {
                    width: 80;
                    height: layer.expanded ? 80 : 0

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
    }
}