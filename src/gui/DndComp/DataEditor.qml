import QtQuick
import QtQuick.Controls

Rectangle {
    id: dataEditor
    anchors.fill: parent

    property string name: ""
    property var paraList: []
    property var setData: {"Null": 0}

    signal editData(var data)
    signal edit(var data)

    Text {
        id: title
        text: name
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 50
        font.underline: true
        horizontalAlignment: Text.AlignLeft
    }

    Column {
         anchors {
            top: title.bottom
            right: parent.right
            left: parent.left
            bottom: setButton.top
        }
        
        Repeater {
            model: paraList

            delegate: textEdit
        }
    }

    function gui(type) {
        switch(type) {
        case 0:
            return textEdit
        }
    }

    Component {
        id: textEdit

        Row {
            id: editRow
            spacing: 10

            Text {
                width: 50
                height: 50

                text: modelData.Name
            }

            TextField {

                width: title.width - 50
                height: 50
                placeholderText: text


                Component.onCompleted: {
                    text = modelData.Value
                }

                onAccepted: {
                    dataEditor.setData[modelData.Name] = text
                }
            }
        }
    }

    Component {
        id: checkBoxEdit

        CheckBox {
            property string key: ""
            property bool value: false
            
            height: 50
            Component.onCompleted: {
                checked = value
            }
            onCheckedChanged: {
                setData[key] = checked
            }
        }
    }

    Component {
        id: switchEdit

        CheckBox {
            property string key: ""
            property bool value: false
            
            height: 50
            Component.onCompleted: {
                 checked = value
            }
            onCheckedChanged: {
                setData[value] = checked
            }
        }
    }

    Button {
        id: setButton
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 50

        text: "确定"

        onClicked: {
            editData(setData)
        }
    }
}