import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window

Window {
    id: msg
    visible: true
    width: 400
    height: 200
    title: "保存和退出"

    //模态
    modality: Qt.WindowModal
    //固定窗口大小
    minimumWidth: 300
    maximumWidth: 300
    minimumHeight: 200
    maximumHeight: 200

    Column {
        spacing: 20

        Text {
            id: tips
            text: qsTr("是否保存项目?")
        }

        Row {
            spacing: 20

            Button {
                id: save
                text: "保存"
                width: 60
                height: 40

                onClicked: {
                    mainWindow.closeType = 1
                    msg.close()
                }
            }

            Button {
                id: dicored
                text: "取消"
                width: 60
                height: 40

                onClicked: {
                    mainWindow.closeType = 2
                    msg.close()
                }
            }

            Button {
                id: exit
                text: "不保存"
                width: 60
                height: 40

                onClicked: {
                    mainWindow.closeType = 3
                    msg.close()
                }
            }
        }
    }
}
