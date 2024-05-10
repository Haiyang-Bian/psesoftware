import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window
import QtQuick.Layouts

Window {
    id: w
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

	RowLayout {
        spacing: 20
        Layout.topMargin: 50

        Label {
            text: "请输入项目名称:"
        }
        TextField {
            id: t1
            placeholderText: qsTr("")
        }
    }

    Button {
        width: 100
        height: 50
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "确定"
        onClicked: {
            tree.createItem(t1.text)
            w.close()
        }
    }
}
