import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: modelMaterials
    visible: true
    width: 700
    height: 700
    anchors.margins: 2
    border.color: "black"
    border.width: 2

    property int mindex: 0

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        Rectangle {
            id: materialList

            // 左侧列表
            SplitView.minimumWidth: 200
            SplitView.preferredWidth: 200
            color: "#DEBEFD"
            border.color: "black"
            border.width: 2

            Rectangle {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                border.color: "black"
                border.width: 2

                Text {
                    text: qsTr("物质列表")
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton

                    onSingleTapped: (eventPoint, button) => {
                        contextMenu.popup(eventPoint.position)
                    }
                }
            }

            ListView {
                id: materialListView
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                model: fluids

                delegate: Rectangle {
                    width: materialList.width
                    height: 50
                    border.color: "black"
                    border.width: 2

                    Text {
                        anchors.fill: parent
                        text: name
                    }

                    TapHandler {
                        
                        acceptedButtons: Qt.RightButton | Qt.LeftButton

                        onDoubleTapped: (eventPoint, button) => {
                            let pageIndex = isPageExist(modelData)
                            if (button === Qt.LeftButton) {
                                if (pageIndex > -1)
                                    stackLayout.currentIndex = pageIndex
                                else {
                                    let win = Qt.createComponent("qrc:/model/Model/MaterialEditor.qml")
                                    if (win.status !== Component.Ready){
                                        console.debug(win.errorString())
                                    }
                                    var ms = win.createObject(workSpace,
                                        {
                                            "width": workSpace.width,
                                            "height": workSpace.height - 50,
                                            "propsName": name
                                        }
                                    )
                                    ms.setMedia.connect((data)=>{
                                        modelWindow.models.editData(modelBuilder.model, data, "Medias")
                                    })
                                    headers.append({
                                        "title": "工质编辑(" + name + ")",
                                        "name": name,
                                        "materialIndex": index,
                                    })
                                    pages.append(ms)
                                    stackLayout.currentIndex = pages.count - 1
                                }
                            }
                        }

                        onSingleTapped: (eventPoint, button) => {
                            if (button === Qt.RightButton) {
                                contextMenu.popup(eventPoint.position)
                                mindex = index
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            // 中间的栈布局
            id: workSpace
            color: "#BC8CE6"
            SplitView.minimumWidth: 200
            SplitView.fillWidth: true
            border.color: "black"
            border.width: 2

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
                        width: Math.min(300, workSpace.width / headers.count)

                        Row {
                            anchors.fill: parent

                            ToolButton {
                                width: parent.width - 50
                                icon.source: "qrc:/icons/Icons/CarbonAccumulationRain.svg"
                                text: title
                                onClicked: {
                                    projectWindows.currentIndex = index
                                }
                            }

                            ToolButton {
                                width: 50
                                property int pageIndex: index
                                action: closeAction
                            }
                        }
                    }
                }
            }

            StackLayout {
                id: stackLayout
                anchors {
                    right: parent.right
                    left: parent.left
                    top: navigationBar.bottom
                    bottom: parent.bottom
                }

                Repeater {
                    model: pages
                }
            }
        }
    }

    ListModel {
        id: headers
    }

    ListModel {
        id: fluids
    }

    Action {
        id: closeAction
        icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
        onTriggered: source => {
            let index = source.pageIndex
            headers.remove(index)
            if (index === stackLayout.currentIndex && headers.count !== 0) {
                stackLayout.currentIndex = index - 1
            }
            pages.remove(index)
        }
    }

    ObjectModel{
        id: pages
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: "新建物质";
            onTriggered: {
                fluids.append({
                    "name": "NewMaterials" + fluids.count
                })

            }
        }
        MenuItem {
            text: "删除物质";
            onTriggered: {
                let name = fluids.get(mindex).name
                fluids.remove(mindex)
                for (let i = 0; i < pages.count; ++i){
                    if (pages.get(i).propsName === name) {
                        pages.remove(i)
                        headers.remove(i)
                        if (i === stackLayout.currentIndex && stackLayout.count > 0)
                            stackLayout.currentIndex = stackLayout.count - 1
                        break
                    }
                }
            }
        }
    }

    function isPageExist(name) {
        for (let i = 0; i < headers.count; ++i) {
            let m = headers.get(i)
            if (m.name === name)
                return i
        }
        return -1
    }
}
