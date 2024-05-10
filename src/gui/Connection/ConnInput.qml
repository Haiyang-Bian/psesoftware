import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    id: newWindow
    visible: true
    width: 300
    height: 200
    modality: Qt.WindowModal
    minimumWidth: 300
    maximumWidth: 300
    minimumHeight: 200
    maximumHeight: 200
    title: "新建连接类型"

    signal createConn(string name)

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        Row {
            Label { text: "名称" }
            TextField {
                id: nameInput
                placeholderText: "请输入连接名称"
                Layout.fillWidth: true
            }
        }

        Row {
            Label { text: "描述" }
            TextField {
                id: descriptionInput
                placeholderText: "请输入该连接的描述"
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: 10

            Button {
                text: "确定"
                onClicked: {
                    connWindow.typeList.appendType({
                        "Type": nameInput.text,
                        "Description": descriptionInput.text
                    })
                    newWindow.createConn(nameInput.text)
                }
            }

            Button {
                text: "取消"
                onClicked: {
                    newWindow.close()
                }
            }
        }
    }
}
