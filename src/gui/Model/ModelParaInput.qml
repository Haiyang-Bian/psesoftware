import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    visible: true
    width: 500
    height: 400
    //模态
    modality: Qt.WindowModal
    //固定窗口大小
    minimumWidth: 500
    maximumWidth: 500
    minimumHeight: 400
    maximumHeight: 400

    flags: Qt.Window | Qt.WindowFixedSize
    title: "参数输入"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        // 参数名称输入框
        RowLayout {
            spacing: 20

            Label {
                text: "请输入参数名称:"
            }
            TextField {
                id: t1
                placeholderText: qsTr("参数名称")
            }
        }

        // 参数类型下拉列表
        RowLayout {
            spacing: 20

            Label {
                text: qsTr("选择参数类型")
            }
            ComboBox {
                id: varComboBox
                model: Controler.getVarTypes(modelWindow.pname)
                textRole: "name"
                valueRole: "name"
            }
        }

        // 单位输入框
        RowLayout {
            spacing: 20

            Label {
                text: "请输入参数单位:"
            }
            TextField {
                id: t2
                placeholderText: qsTr("单位")
            }
        }
        
        // 参数值输入框
        RowLayout {
            spacing: 20

            Label {
                text: "请输入参数值:"
            }
            TextField {
                id: t3
                placeholderText: "0.0"
            }
        }

        RowLayout {
            spacing: 20

            Label {
                text: "请输入参数数目:"
            }
            TextField {
                id: t4
                placeholderText: "1"
            }
        }

        RowLayout {
            spacing: 20

            Label {
                text: "请输入GUIMetaData:"
            }
            TextField {
                id: t5
                placeholderText: "text"
            }
        }

        RowLayout {
            spacing: 20

            Button {
                text: "确认"
                onClicked: {
                    varAndPara.createData({
                        "Name": t1.text,
                        "Type": varComboBox.currentValue,
                        "Unit": t2.text,
                        "Value": t3.text,  
                        "Number": t4.text,
                        "Gui": t5.text
                    }, 2)
                }
            }

            Button {
                text: "取消"
                onClicked: {
                    close()
                }
            }
        }
    }
}
