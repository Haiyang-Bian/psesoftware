import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    id: window
    visible: true
    width: 400
    height: 200
    title: "新建模型"

    signal confirmCreation()

    RowLayout {
        anchors.fill: parent
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Row {
                spacing: 10
                Label {
                    text: "请输入模型名称:"
                }
                TextField {
                    id: modelNameField
                    placeholderText: "模型名称"
                }
            }

            Row {
                spacing: 10
                Label {
                    text: "请输入模型的描述信息:"
                }
                TextArea {
                    id: modelDescriptionField
                    placeholderText: "模型描述"
                    Layout.fillHeight: true
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true

            Button {
                text: "确认"
                Layout.alignment: Qt.AlignBottom
                onClicked: {
                    modelWindow.models.appendType(modelNameField.text)
                    window.confirmCreation()
                    modelWindow.models.appendDes(modelDescriptionField.text)
                    window.close()
                }
            }

            Button {
                text: "取消"
                Layout.alignment: Qt.AlignTop
                onClicked: {
                    window.close()
                }
            }
        }
    }
}

