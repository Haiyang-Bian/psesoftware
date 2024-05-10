import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    visible: true

    border.color: "black"
    border.width: 2
    anchors.margins: 2

    Component.onCompleted: {
        text.forceActiveFocus()
    }

    Action {
        id: open
        icon.source: "qrc:/icons/Icons/CodiconFolder.svg"
        onTriggered: {
            text.forceActiveFocus()
        }
    }

    Action {
        id: save
        icon.source: "qrc:/icons/Icons/CodiconSave.svg"
        onTriggered: {
            modelWindow.models.editEquations(modelBuilder.model, textEdit.text)
            text.forceActiveFocus()
        }
    }



    ToolBar {
        id: tools
        anchors.top: parent.top
        anchors.left: parent.left
        contentHeight: toolBarRow.height
        width: parent.width
        anchors.margins: 2
        height: 50

        Row {
            id: toolBarRow
            anchors.fill: parent

            spacing: 10
            ToolButton { action: open }
            ToolButton { action: save }
        }
    }

    FocusScope {
        id: text
        height: parent.height - 40
        width: parent.width
        anchors {
            left: parent.left
            top: tools.bottom
            margins: 2
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 2

            ListView {
                id: lineNumberView
                Layout.leftMargin: 2 
                Layout.bottomMargin: 2 
                Layout.fillHeight: true
                width: 50

                model: textEdit.lineCount

                clip: true

                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    width: 50
                    height: textEdit.cursorRectangle.height
                    Text {
                        text: index + 1
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignRight
                        color: (index === textEdit.cursorRectangle.y / textEdit.cursorRectangle.height) ? "black" : "grey"
                    }
                }
            }

            Rectangle {
                Layout.maximumWidth: 3
                Layout.minimumWidth: 3
                Layout.topMargin: 2 
                Layout.bottomMargin: 2 
                Layout.fillHeight: true
                color: "green"
            }

            Flickable {
                id: flick
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 2

                contentWidth: textEdit.paintedWidth
                contentHeight: textEdit.paintedHeight
                boundsBehavior: Flickable.StopAtBounds

                clip: true

                ScrollBar.vertical: ScrollBar {
                    id: verticalScrollBar
                    policy: ScrollBar.AlwaysOn // 滚动条始终显示
                    minimumSize: 0.15
                }

                ScrollBar.horizontal: ScrollBar {
                    id: hsb
                    policy: ScrollBar.AlwaysOn // 滚动条始终显示
                    minimumSize: 0.15
                }

                TextEdit {
                    id: textEdit
                    focus: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: TextEdit.Wrap
                    //textFormat: Text.RichText // 启用富文本格式
                    font.family: "monospace"

                    onTextChanged: {
                        lineNumberView.height = textEdit.cursorRectangle.height * textEdit.lineCount
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_S && (event.modifiers & Qt.ControlModifier)) {
                            var lines = textEdit.text.split(/[\r\n]+/);
                            modelWindow.models.setEqs(lines ,modelWindow.modelId)
                            event.accepted = true
                        }
                    }

                    Component.onCompleted: {
                        let eqs = modelWindow.models.getData(modelBuilder.model, "Equations")
                        textEdit.text = eqs
                    }
                }

                onContentYChanged: {
                    lineNumberView.contentY = flick.contentY
                }
            }
        }
    }
}
