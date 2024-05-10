import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    id: newWindow
    visible: true
    width: 350
    height: 200
    title: "新建端口变量"
    modality: Qt.WindowModal
    minimumWidth: 350
    maximumWidth: 350
    minimumHeight: 200
    maximumHeight: 200

    signal create(string name, string des)

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        Row {
            Label { text: "名称" }
            TextField {
                id: nameInput
                placeholderText: "请输入变量名称"
                Layout.fillWidth: true
            }
        }

        Row {
            Label { text: "描述" }
            TextField {
                id: descriptionInput
                placeholderText: "请输入该变量的描述"
                Layout.fillWidth: true
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: 10

            Button {
                text: "确定"
                onClicked: {
                    // 在这里添加确定按钮的逻辑
                    newWindow.create(nameInput.text, descriptionInput.text)
                    connWindow.typeList.createConnectionVar({
                        "Name":  nameInput.text,
                        "Connect": "Equal",
                        "Description": descriptionInput.text
                    }, connList.connId)
                }
            }

            Button {
                text: "取消"
                onClicked: {
                    // 在这里添加取消按钮的逻辑
                    newWindow.close()
                }
            }
        }
    }
}
