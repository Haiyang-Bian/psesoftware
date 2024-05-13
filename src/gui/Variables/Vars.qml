import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Window
import Qt.labs.qmlmodels
import QtQuick.Dialogs 
import Ai4Energy 1.0

Rectangle {
    id: subWindow
    
	width: 800
    height: 800
	visible: true
    clip: true
    
    property VarModel varTypes: undefined


    Rectangle {
        id: tableHeader
        anchors.left: subWindow.left
        anchors.right: subWindow.right
        anchors.top: parent.top
        border.color: "black"
        border.width: 3
        height: 50

        Row {
            anchors.fill: parent
            
            Repeater {
                model: ["变量类型名称", "单位", "默认值", "下限", "上限"]
            
                delegate: Rectangle {
                    width: (tableHeader.width - 50) / 5
                    height: 50
                    border.color: "black"
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                    }

                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onSingleTapped: {
                            editMenu.popup(point)
                        }
                    }
                }
            }

            Button {
                icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                width: 50
                height: 50
                onClicked: {
                    let data = {
                        "Name": "NewVar", //+ varList.count,
                        "Unit": 1,
                        "DefaultValue": 0,
                        "Min": "-Inf",
                        "Max": "Inf",
                    }
                    varTypes.appendType(data)
                }
            }

            Menu {
                id: editMenu
                Repeater {
                    model: ["导入", "使用标准变量类型", "新建", "编辑", 
                    "删除", "保存", "选择导入文件", "选择导出文件"]

                    delegate: MenuItem {
                        width: 200
                        height: 50
                        text: modelData

                        background: Rectangle {
                            implicitHeight: 50
                            implicitWidth: 100
                            border.color: "black"
                            border.width: 2
                            color: "#FF9DE5"
                            radius: 5
                        }

                        onTriggered: {
                            buttonEvents(index)
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: table
        anchors.left: subWindow.left
        anchors.leftMargin: 3
        anchors.right: subWindow.right
        anchors.rightMargin: 3
        anchors.bottom: subWindow.bottom
        anchors.top: tableHeader.bottom
        clip: true

        model: varTypes

        delegate: Rectangle {
            width: table.width
            height: 50

            property int rindex: index

            Row {

                Repeater {
                    model: 5
                
                    delegate: TextField {
                        width: (table.width - 50) / 5
                        height: 50
                        placeholderText: varTypes.getType(rindex, index)
                        placeholderTextColor: "black"
                        onAccepted: {
                            varTypes.editType()
                        }
                    }
                }

                Button {
                    icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
                    width: 50
                    height: 50
                    onClicked: {
                        varTypes.removeVariable(index)
                    }
                }
            }
        }
    }

// 功能区-------------------------------------------------------------------------

    function buttonEvents(type) {
        switch(type){
        case 0:
            openFile.visible = true
            break;
        case 1:
            varTypes.loadTypesFromDataBase()
            break;
        case 2:
            loader2.source = "/variable/Variables/VarInput.qml"
            loader2.active = true
            break;
        case 3:
            if (rectangle.editIndex !== -1) {
                loader2.source = "/variable/Variables/VarEdit.qml"
                loader2.active = true
            }
            break;
        case 4:
            for (let i = 0; i < table.deletVars.length; i++) {
                table.deletVars[i] -= i
            }
            table.deletVars.forEach(item => {
                subWindow.varTypes.removeVariable(item)
            })
            table.deletVars = []
            break;
        case 5:
            saveFile.visible = true
            break;
        }
    }
    
    FileDialog {
        id: openFile
        title: "选择导入文件"
        visible: false
        fileMode: FileDialog.OpenFile
        onAccepted: {
            varTypes.loadTypes(openFile.selectedFile.toString())
        }
        onRejected: {
            
        }
    }

    FileDialog {
        id: saveFile
        title: "选择导出文件"
        visible: false
        fileMode: FileDialog.SaveFile
        onAccepted: {
            subWindow.varTypes.saveTypes(saveFile.selectedFile.toString())
        }
        onRejected: {
            
        }
    }

    Loader {
        id: loader2
        active: false 
        source: "" 
        onLoaded: {
            loader2.item.closing.connect(()=>{
                loader2.source = ""
                loader2.active = false
            })
        }
    }
}
