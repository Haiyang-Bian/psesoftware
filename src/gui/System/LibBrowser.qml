import QtQuick 2.3
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window

Window {
    title: "库浏览器"
    visible: true
    width: 400
    height: 400

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: liblist
            Layout.preferredWidth: parent.width * 0.8 - 2
            Layout.preferredHeight: parent.height - 2
            color: "#f0f0f0" // 背景颜色
            border.color: "black" // 边框颜色
            border.width: 1
            radius: 5 // 边框圆角

            ScrollView {
                width: parent.width
                height: parent.height
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                ListView {
                    anchors.fill: parent
                    flickableDirection: Flickable.VerticalFlick

                    model: libs
                    delegate: Item {
                        width: liblist.width
                        height: 40
                        RowLayout {
                            CheckBox {
                                id: checkbox
                                enabled: model.enabled
                                checked: model.enabled

                                onCheckedChanged: {
                                    model.selected = this.checked; // 更新模型中的状态
                                }
                            }
                            Label {
                                text: model.name
                                color: model.enabled ? "black" : "grey"
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width * 0.2
            Button {
                text: "确认"
                onClicked: {
                    // 确认按钮的逻辑
                    // 遍历ListModel
                    var arr = []
                    for (var i = 0; i < libs.count; ++i) {
                        var item = libs.get(i);
                        if (item.enabled && item.selected) {
                            arr.push(item.name)
                        }
                    }   
                    Controler.selectLibs(arr)
                }
            }
            Button {
                text: "取消"
                onClicked: {
                    // 取消按钮的逻辑
                }
            }
        }
    }

// 功能区-----------------------------------------------------------------------------
    ListModel {
        id: libs
        ListElement { name: "ElectricalStandardLibrary"; enabled: true; selected: false }
        ListElement { name: "PhotovoltaicElectrolysisHydrogenStorageStandardLibrary"; enabled: true; selected: false }
        ListElement { name: "ThermalStandardLibrary"; enabled: false; selected: false }
        ListElement { name: "FluidStandardLibrary"; enabled: false; selected: false }
    }
}