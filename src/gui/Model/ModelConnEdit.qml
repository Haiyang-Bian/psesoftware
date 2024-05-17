import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    id: connEdit
    visible: true
    width: 350
    height: 450
    title: "接口编辑"

    modality: Qt.WindowModal

    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height

    signal createConn(var data)

    property var connTypes: Controler.getConnTypes(modelWindow.pname)

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        RowLayout {
            Label {
                text: qsTr("接口名称：")
            }
            TextField {
                id: nameInput
                Layout.fillWidth: true
                placeholderText: qsTr("请输入名称")
            }
        }

        RowLayout {
            Label {
                text: qsTr("接口类型：")
            }
            ComboBox {
                id: typeInput
                textRole: "Type"
                valueRole: "Type"
                Layout.fillWidth: true
                model: connTypes

                Component.onCompleted: {
                    currentIndex = connTypes.getIndexByType(Type)
                }
            }
        }

        RowLayout {
            Label {
                text: qsTr("接口个数：")
            }
            TextField {
                id: numberInput
                Layout.fillWidth: true
                placeholderText: qsTr("请输入个数")
            }
        }

        RowLayout {
            Label {
                text: qsTr("接口位置：")
            }
            TextField {
                id: pInput
                Layout.fillWidth: true
                placeholderText: qsTr("请输入位置")
            }
        }

        RowLayout {
            Label {
                text: qsTr("位置偏移量：")
            }
            TextField {
                id: oInput
                Layout.fillWidth: true
                placeholderText: qsTr("请输入偏移量")
            }
        }

        RowLayout {
            Button {
                text: qsTr("确认")
                height: 50
                width: 70

                background: Rectangle {
                    color: parent.down ? "lightblue" : "white" 
                    radius: 5
                    border {
                        color: "black"
                        width: 1
                    }
                }

                onClicked: {
                    connEdit.createConn({
                        "Name": nameInput.text,
                        "Type": typeInput.currentValue, 
                        "Number": numberInput.text,
                        "Position": pInput.text,
                        "Offset": oInput.text
                    })
                }
            }

            Button {
                text: qsTr("取消")
                height: 50
                width: 70

                background: Rectangle {
                    color: parent.down ? "lightblue" : "white" 
                    radius: 5
                    border {
                        color: "black"
                        width: 1
                    }
                }

                onClicked: {
                    close()
                }
            }
        }
    }
}
