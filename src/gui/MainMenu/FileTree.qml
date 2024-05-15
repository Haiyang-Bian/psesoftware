import QtQuick
import QtQuick.Controls
import Ai4Energy 1.0

Rectangle {
    id: projectTree
    visible: true

    signal createItem(string name)
    signal editItem(string name, int type)

    onCreateItem: name => {
        tree_model.createItem(name);
    }

    TreeModel {
       id: tree_model
    }

    TreeView {
        id: treeView
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        selectionModel: ItemSelectionModel {}

        model: tree_model


        delegate: Item {
            implicitWidth: padding + label.x + label.implicitWidth + icon.implicitWidth + padding
            implicitHeight: 40

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
                anchors.margins: 2
                color: "transparent"

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

                Image {
                    id: icon
                    x: padding + (isTreeNode ? depth * indentation : 0) + padding
                    source: isTreeNode && hasChildren ? iconChange(expanded) : getIcon(row)
                }

                Label {
                    id: label
                    x: padding + (isTreeNode ? (depth + 1) * indentation : 0) + padding + icon.implicitWidth
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - padding - x
                    clip: true
                    text: model.display

                    TapHandler {
                        onDoubleTapped: {
                            if (depth === 1) {
                                var p = tree_model.parent(treeView.index(row, column))
                                var pname = tree_model.data(p, 0)
                                projectTree.editItem(pname, treeView.index(row, column).row)
                            }
                        }
                    }
                }
            }

            function iconChange(s) {
                if (s)
                    return "qrc:/icons/Icons/CodiconFolderOpened.svg"
                else
                    return "qrc:/icons/Icons/CodiconFolder.svg"
            }

            function getIcon(type) {
                switch(type){
                case 1:
                    return "qrc:/icons/Icons/CarbonValueVariable.svg"
                case 2:
                    return "qrc:/icons/Icons/CarbonConnect.svg"
                case 3:
                    return "qrc:/icons/Icons/CarbonModelAlt.svg"
                case 4:
                    return "qrc:/icons/Icons/CarbonModelBuilder.svg"
                }
            }
        }
    }
}