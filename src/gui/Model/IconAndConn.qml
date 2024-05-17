import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Qt.labs.qmlmodels
import QtQuick.Dialogs

Rectangle {
    id: iconConn
    visible: true
    width: 800
    height: 800
    border.color: "black"
    border.width: 3
    anchors {
        leftMargin: 2
        rightMargin: 2
        topMargin: 2
        bottomMargin: 2
    }

    signal setPort()

    SplitView {
        anchors {
            fill: parent
            leftMargin: 2
            rightMargin: 2
            topMargin: 2
            bottomMargin: 2
        }

        orientation: Qt.Vertical

        Rectangle {
            SplitView.minimumHeight: parent.height / 4
            SplitView.preferredHeight: 200 
            border.color: "black"
            border.width: 2
            
            Rectangle {
                anchors.centerIn: parent
                width: 80
                height: 80
                color: "grey"

                Image {
                    id: imageView
                    anchors.fill: parent
                    anchors.margins: 2
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton

                    onSingleTapped: {
                        imageSet.popup(point)
                    }
                }


                Menu {
                    id: imageSet

                    MenuItem {
                        text: "添加图片"
                        onTriggered: {
                            fileDialog.open()
                        }
                    }
                    MenuItem {
                        text: "删除图片"
                        onTriggered: {
                            imageView.source = ""
                            modelWindow.models.editIcon(modelBuilder.model, "")
                        }
                    }
                }
            }
        }

        Rectangle {
            SplitView.minimumHeight: 100
            SplitView.fillHeight: true
                
            Rectangle {
                id: tableHeader
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 50
                border.color: "black"
                border.width: 1

                Row {
                    anchors.fill: parent
                    Repeater {
                        model: ["接口名称", "接口类型", "接口数目", "接口位置", "位置偏移量"]

                        delegate: Rectangle {
                            width: tableHeader.width / 5
                            height: 50
                            color: "#C0F3F0"
                            border.color: "black"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                            }
                        }
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton

                    onSingleTapped: {
                        allSet.popup(point)
                    }
                }

                Menu {
                    id: allSet
                    MenuItem {
                        text: "新建连接类型"
                        onTriggered: {
                            loader.source = "/model/Model/ModelConnEdit.qml"
                            loader.active = true
                        }
                    }
                    MenuItem {
                        text: "清空列表"
                        onTriggered: {

                        }
                    }
                }
            }

            Rectangle {
                anchors {
                        left: parent.left
                        right: parent.right
                        top: tableHeader.bottom
                        bottom: parent.bottom
                }

                ListView {
                    id: editList
                    anchors.fill: parent

                    clip: true
                    
                    model: connList

                    delegate: editDelegate
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "请选择一个图片文件"
        nameFilters: ["图片文件 (*.png *.jpg *.jpeg)"]
        onAccepted: {
            imageView.source = fileDialog.selectedFile
            modelWindow.models.editIcon(modelBuilder.model, fileDialog.selectedFile)
        }
    }

    ListModel {
        id: connList
    }

    Component.onCompleted: {
        let arr = modelWindow.models.getData(modelBuilder.model, "Ports")
        if (arr.length > 0) {
            arr.forEach(conn=>{
                connList.append({
                    "Name": conn.Name,
                    "Type": conn.Type,
                    "Number": conn.Number,
                    "Position": conn.Position,
                    "Offset": conn.Offset
                })
            })
        }
        let icon = modelWindow.models.getIcon(modelBuilder.model)
        if (icon != ""){
            imageView.source = icon
        }
    }

    Loader {
        id: loader
        active: false
        anchors.fill: parent
        source: ""
        onLoaded: {
            loader.item.closing.connect(()=>{
                loader.source = ""
            })
            item.createConn.connect((data)=>{
                connList.append(data)
                modelWindow.models.editPort(modelBuilder.model, data)
                setPort()
            })
        }
    }

    Component {
        id: editDelegate
        Rectangle {
            width: parent.width
            height: 50
            Text {
                id: t1
                anchors.left: parent.left
                width: parent.width / 5
                text: Name
            }
            Text {
                id: t2
                anchors.left: t1.right
                width: parent.width / 5
                text: Type
            }
            Text {
                id: t3
                anchors.left: t2.right
                width: parent.width / 5
                text: Number
            }
            Text {
                id: t4
                anchors.left: t3.right
                width: parent.width / 5
                text: Position
            }
            Text {
                id: t5
                anchors.left: t4.right
                width: parent.width / 5
                text: Offset
            }

            TapHandler {
                id: tap
                acceptedButtons: Qt.RightButton

                onSingleTapped: {
                    singleSet.popup(point)
                }
            }

            Menu {
                id: singleSet
                MenuItem {
                    text: "编辑"
                    onTriggered: {
                        loader.source = "/model/Model/ModelConnEdit.qml"
                        loader.active = true
                    }
                }
                MenuItem {
                    text: "删除"
                    onTriggered: {
                        modelWindow.models.editPort(modelBuilder.model, {
                            "Name": Name
                        })
                        connList.remove(index)
                    }
                }
            }
        }
    }
}
