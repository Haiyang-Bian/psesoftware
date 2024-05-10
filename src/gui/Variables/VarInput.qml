import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
	id: window
    visible: true
    width: 400
    height: 300
    title: "输入窗口"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Row {
            spacing: 10
            Label { text: "变量类型名称：" }
            TextField {
                id: typeField
                width: 200
                placeholderText: "请输入变量类型名称"
            }
        }

        Row {
            spacing: 10
            Label { text: "单位：" }
            TextField {
                id: unitField
                width: 200
                placeholderText: "请输入单位"
            }
        }

        Row {
            spacing: 10
            Label { text: "默认值：" }
            TextField {
                id: defaultField
                width: 200
                placeholderText: "请输入默认值"
                // 验证输入是否为数字
                validator: DoubleValidator {} 
            }
        }

        Row {
            spacing: 10
            Label { text: "下限：" }
            TextField {
                id: lowerField
                width: 200
                placeholderText: "请输入下限"
            }
        }

        Row {
            spacing: 10
            Label { text: "上限：" }
            TextField {
                id: upperField
                width: 200
                placeholderText: "请输入上限"
            }
        }

        Button {
            text: "确认"
            onClicked: {
				subWindow.varTypes.insertVariable({
                    "id": subWindow.varTypes.rowCount(),
                    "name": typeField.text,
                    "unit": unitField.text,
                    "defaultValue": Number(defaultField.text),
                    "min": lowerField.text,
                    "max": upperField.text,
                }, subWindow.varTypes.rowCount())
            }
        }
    }
}
