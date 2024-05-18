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


        delegate: treee
    }

    Component {
        id: treee

        Rectangle {
            id: layer

            implicitWidth: treeView.width
            implicitHeight: type ? Math.ceil(libModels.length / 2) * 100 : 50

            border {
                color: "black"
                width: 1
            }

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
                anchors {
                    top: layer.top
                    left: layer.left
                    right: !type ? layer.right : layer.left
                }
                height: !type ? 50 : 0

                clip: true
                text: name

                TapHandler {
                    onDoubleTapped: {
                        let index = treeView.index(row, column)
                        treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                        treeView.toggleExpanded(row)
                    }
                    onSingleTapped: {
                        let index = treeView.index(row, column)
                        treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                        treeView.toggleExpanded(row)
                    }
                }
            }

            GridView {
                id: modelsView
                visible: type
                anchors {
                    top: label.bottom
                    left: layer.left
                    right: layer.right
                    bottom: layer.bottom
                }

                cellWidth: 80 
                cellHeight: 80 

                clip: true
                z: 100
                
                model: libModels
                
                delegate: Loader {
                    visible: true
                    width: 80
                    height: 80
                    active: true
                
                    source: "qrc:/dndkit/DndComp/DragComponent.qml"
                
                    onLoaded: {
                        item.paras = modelData.Paras
                        item.compType = modelData.Type
                        item.image = modelData.Icon
                        item.hdata = modelData.Handlers
                        item.dnd = prosessWindow.sysDnd
                    }
                }
            }
        }
    }
}