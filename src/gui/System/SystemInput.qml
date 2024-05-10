import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    id: window
    visible: true
    width: 400
    height: 200
    title: "新建过程"

    signal confirmCreation(string name)

    RowLayout {
        anchors.fill: parent
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Row {
                spacing: 10
                Label {
                    text: "请输入过程名称:"
                }
                TextField {
                    id: sysName
                    placeholderText: "过程名称"
                }
            }

            Row {
                spacing: 10
                Label {
                    text: "请输入过程的描述信息:"
                }
                TextArea {
                    id: sysDes
                    placeholderText: "过程描述"
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
                    window.confirmCreation(sysName.text)
                    Controler.createSystem(sysWindow.pname, sysName.text)
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
