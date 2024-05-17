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

    signal save()
    signal dicored()
    signal notSave()

    onClosing: {
        msg.dicored()
    }

    Column {
        anchors.fill: parent
        spacing: 5

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 3
            radius: 5
            border.color: "black"
            border.width: 1
            height: parent.height - 60
            Text {
                id: tips
                anchors.centerIn: parent
                text: qsTr("是否保存项目?")
            }
        }

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            spacing: 20

            Button {
                id: save
                text: "保存"
                width: (parent.width - 60) / 3
                height: 40

                onClicked: {
                    msg.save()
                }
            }

            Button {
                id: dicored
                text: "取消"
                width: (parent.width - 60) / 3
                height: 40

                onClicked: {
                    msg.dicored()
                    msg.close()
                }
            }

            Button {
                id: exit
                text: "不保存"
                width: (parent.width - 60) / 3
                height: 40

                onClicked: {
                    msg.notSave()
                    msg.close()
                }
            }
        }
    }
}
