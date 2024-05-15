import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window

Window {
    id: projectCreator
    visible: true
	width: 300
	height: 200

    //模态
    modality: Qt.WindowModal
    //固定窗口大小
    minimumWidth: 300
    maximumWidth: 300
    minimumHeight: 200
    maximumHeight: 200

    signal creatProject(string name)

	Rectangle {
        anchors.fill: parent
        anchors.margins: 2

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 50
            text: "请输入项目名称:"
        }
        TextField {
            id: t1
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 100
            height: 50
            placeholderText: qsTr("新的项目")
            onAccepted: {
                projectCreator.creatProject(text)
                projectCreator.close()
            }
        }
    }
}
