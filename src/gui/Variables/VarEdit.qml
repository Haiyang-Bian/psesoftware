import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
	id: editWindow
    visible: true
    width: 400
    height: 300
    title: "编辑窗口"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Row {
            spacing: 10
            Label { text: "变量类型名称：" }
            TextField {
                id: typeField
                width: 200
                placeholderText: subWindow.varTypes.getType(rectangle.editIndex, 2)
            }
        }

        Row {
            spacing: 10
            Label { text: "单位：" }
            TextField {
                id: unitField
                width: 200
                placeholderText: subWindow.varTypes.getType(rectangle.editIndex, 3)
            }
        }

        Row {
            spacing: 10
            Label { text: "默认值：" }
            TextField {
                id: defaultField
                width: 200
                placeholderText: subWindow.varTypes.getType(rectangle.editIndex, 4)
                validator: DoubleValidator {} // 验证输入是否为数字
            }
        }

        Row {
            spacing: 10
            Label { text: "下限：" }
            TextField {
                id: lowerField
                width: 200
                placeholderText: subWindow.varTypes.getType(rectangle.editIndex, 5)
            }
        }

        Row {
            spacing: 10
            Label { text: "上限：" }
            TextField {
                id: upperField
                width: 200
                placeholderText: subWindow.varTypes.getType(rectangle.editIndex, 6)
            }
        }

        Button {
            text: "确认"
            onClicked: {
                subWindow.varTypes.editType({
                    "name": typeField.text,
                    "unit": unitField.text,
                    "defaultValue": defaultField.text,
                    "min": lowerField.text,
                    "max": upperField.text
                }, rectangle.editIndex)
            }
        }
    }
}
