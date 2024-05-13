import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: editDelegate
    width: parent.width
    height: 50
    anchors.margins: 2

    signal rename(string name)
    signal edit(int type, var data)

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: (editDelegate.width -50) / 3
            Layout.preferredHeight: 50
            border {
                color: "black"
                width: 2
            }
            TextField {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter 

                Component.onCompleted: text = Name

                onAccepted: {
                    rename(text)
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: (editDelegate.width -50) / 3
            Layout.preferredHeight: 50
            border {
                color: "black"
                width: 2
            }
            // 类型下拉框
            ComboBox {
                textRole: "name"
                valueRole: "name"
                anchors.margins: 2
                anchors.fill: parent

                model: editWindow.varTypes

                Component.onCompleted: {
                    currentIndex = getVarIndex(Type)
                }
                
                onActivated: {
                    if (currentValue !== undefined) {
                        console.log("为啥呀")
                        edit(1, currentValue)
                    }
                }

                delegate: ItemDelegate {
                    width: editDelegate.width / 3
                    height: 40
                    Text {
                        text: name
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: (editDelegate.width -50) / 3
            Layout.preferredHeight: 50
            border {
                color: "black"
                width: 2
            }
            
            ComboBox {
                anchors.fill: parent
                anchors.margins: 2
                
                model: ListModel {
                    ListElement{ type:"Equal" }
                    ListElement{ type:"Flow" }
                    ListElement{ type:"Stream" }
                }

                Component.onCompleted: {
                    currentIndex = getConnTypeIndex(ConnectType)
                }
                
                onActivated: {
                    
                    if (currentValue !== undefined) {
                        edit(2, currentValue)
                    }
                }

                delegate: ItemDelegate {
                    width: editDelegate.width / 3
                    height: 40
                    Text {
                        text: type
                        font.pixelSize: 20
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Button {
            icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
            width: 50
            height: 50
            onClicked: {
                edit(0, 0)
            }
        }
    }

    function getVarIndex(type) {
        var id = editWindow.varTypes.getIdByType(type)
        if (id === -1) {
            return 0
        }
        else {
            return id
        }
    }

    function getConnTypeIndex(type) {
        switch (type) {
        case "Equal":
            return 0;
        case "Flow":
            return 1;
        case "Stream":
            return 2
        default:
            return 0
        }
    }
}