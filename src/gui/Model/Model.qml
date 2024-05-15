import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "qrc:/model/Model"

Rectangle {
    id: modelBuilder
    visible: true
    width: 1000
    height: 750
    border.color: "black"
    border.width: 2
    color: "#EAF3E0"

    property var model: undefined

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            border.color: "black"
            border.width: 2
            color: "#EAF3E0"
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - tabBar.height

            StackLayout {
                id: stackLayout
                anchors.fill: parent
               
                IconAndConn {
                    id: icAndConn
                    width: parent.width
                    height: parent.height
                }

                ModelVarPara {
                    id: varAndPara
                    width: parent.width
                    height: parent.height
                }

                ModelMaterials {
                    id: materials
                    width: parent.width
                    height: parent.height
                }
                
                TextEditor {
                    id: equations
                    width: parent.width
                    height: parent.height
                }

                ModelSubSystem {
                    id: subSystems
                    width: parent.width
                    height: parent.height
                }

                Connections {
                    target: icAndConn
                    function onSetPort(){
                        subSystems.setPorts()
                    }
                }
            }
        }

        TabBar {
            id: tabBar
            Layout.alignment: Qt.AlignBottom
            Layout.preferredHeight: 35
            Layout.fillWidth: true
            currentIndex: stackLayout.currentIndex

            Repeater {
                model: ["接口", "成员", "工质", "方程", "子系统"]

                delegate: TabButton {
                    text: modelData
           
                    width: 100
                    height: 35

                    background: Rectangle {
                        color: "transparent"
                        border.color: "black"
                        border.width: 2
                    }
                    onClicked: {
                        stackLayout.currentIndex = index
                    }
                }
            }
        }
    }
}