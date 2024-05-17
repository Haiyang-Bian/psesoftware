import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: varAndPara
    visible: true
    
    property var dataTypes: Controler.getVarTypes(modelBuilder.pname)
    
    Layout.margins: 2
    Layout.fillHeight: true
    Layout.fillWidth: true
    border {
        color: "black"
        width: 1
    }

    signal createData(var data, string type)

    Component.onCompleted: {
        var vs = modelWindow.models.getData(modelBuilder.model, "Variables")
        var ps = modelWindow.models.getData(modelBuilder.model, "Parameters")
        if (vs.length > 0) {
            vs.forEach(v => {
                varList.append({
                    "Name": v.Name,
                    "Type": v.Type,
                    "Unit": v.Unit === undefined ? "" : v.Unit,
                    "Min": v.Min === undefined ? "" : v.Min,
                    "Max": v.Max === undefined ? "" : v.Max,
                    "Value": v.Value === undefined ? "" : 0,
                    "Number": v.Number === undefined ? "" : 1
                })
            })
        }
        if (ps.length > 0) {
            ps.forEach(p => {
                paraList.append({
                    "Name": p.Name,
                    "Type": p.Type,
                    "Unit": p.Unit === undefined ? "" : p.Unit,
                    "Min": p.Min === undefined ? "" : p.Min,
                    "Max": p.Max === undefined ? "" : p.Max,
                    "Value": p.Value,
                    "Gui": p.Gui,
                    "Number": p.Number === undefined ? "" : 1
                })
            })
        }
    }

    ToolBar {
        id: editHeader
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 1
        }
        height: 40
        Row {
            spacing: 20
            anchors.fill: parent
            ToolButton {
                icon.source: "qrc:/icons/Icons/CodiconSymbolVariable.svg"

                onClicked: {
                    propsEdit.currentIndex = 0
                }

                ToolTip {
                    visible: parent.hovered
                    text: "变量编辑"
                    background: Rectangle {
                        border {
                            color: "black"
                            width: 1
                        }
                        radius: 5
                    }
                }
            }
            ToolButton {
                icon.source: "qrc:/icons/Icons/CodiconSymbolParameter.svg"

                onClicked: {
                    propsEdit.currentIndex = 1
                }

                ToolTip {
                    visible: parent.hovered
                    text: "参数编辑"
                    background: Rectangle {
                        border {
                            color: "black"
                            width: 1
                        }
                        radius: 5
                    }
                }
            }
            ToolButton {
                icon.source: "qrc:/icons/Icons/CodiconSymbolStructure.svg"

                onClicked: {
                    propsEdit.currentIndex = 2
                }

                ToolTip {
                    visible: parent.hovered
                    text: "结构参数编辑"
                    background: Rectangle {
                        border {
                            color: "black"
                            width: 1
                        }
                        radius: 5
                    }
                }
            }
            ToolButton {
                icon.source: "qrc:/icons/Icons/CodiconSymbolConstant.svg"

                onClicked: {
                    propsEdit.currentIndex = 3
                }

                ToolTip {
                    visible: parent.hovered
                    text: "常数编辑"
                    background: Rectangle {
                        border {
                            color: "black"
                            width: 1
                        }
                        radius: 5
                    }
                }
            }
        }
    }

    StackLayout {
        id: propsEdit
        anchors {
            top: editHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 1
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Row {
                id: varHeader
                anchors.top: parent.top
                width: parent.width
                height: 50

                Repeater {
                    model: ["变量名", "变量类型", "单位", "默认值", "下限", "上限", "数目"]

                    delegate: Rectangle {
                        height: 50
                        width: (varHeader.width - 50) / 7
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                        }
                    }
                }

                Button {
                    icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                    width: 50
                    height: 50
                    onClicked: {
                        let data = {
                            "Name": "NewVar" + varList.count,
                            "Type": "NoUnit",
                            "Unit": 1,
                            "Value": 0,
                            "Min": "-Inf",
                            "Max": "Inf",
                            "Number": 1
                        }
                        varList.append(data)
                        modelWindow.models.editData(modelBuilder.model, data, "Variables")
                    }
                }
            }

            ListView {
                anchors.top: varHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: varList

                delegate: vardele
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Row {
                id: paraHeader
                anchors.top: parent.top
                width: parent.width
                height: 50
                Repeater {
                    model: ["参数名", "参数类型", "单位", "值", "数目", "渲染"]

                    delegate: Rectangle {
                        height: 50
                        width: (paraHeader.width - 50) / 6
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                        }
                    }
                }

                Button {
                    icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                    width: 50
                    height: 50
                    onClicked: {
                        let data = {
                            "Name": "NewPara" + paraList.count,
                            "Type": "NoUnit",
                            "Unit": 1,
                            "Value": 0,
                            "Number": 1,
                            "Gui": 0
                        }
                        paraList.append(data)
                        modelWindow.models.editData(modelBuilder.model, data, "Parameters")
                    }
                }
            }

            ListView {
                anchors.top: paraHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                model: paraList

                delegate: paradele
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Row {
                id: spHeader
                anchors {
                    top: parent.top
                    left: parent.left
                }
                width: parent.width
                height: 50
                Rectangle {
                    height: 50
                    width: (spHeader.width - 50) / 3
                    Text {
                        anchors.centerIn: parent
                        text: "结构参数名称"
                    }
                }
                Rectangle {
                    height: 50
                    width: (spHeader.width - 50) / 3
                    Text {
                        anchors.centerIn: parent
                        text: "值"
                    }
                }
                Rectangle {
                    height: 50
                    width: (spHeader.width - 50) / 3
                    Text {
                        anchors.centerIn: parent
                        text: "渲染"
                    }
                }
                Button {
                    icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                    width: 50
                    height: 50
                    onClicked: {
                        let data = {
                            "Name": "NewSPara" + sparaList.count,
                            "Value": 0,
                            "Gui": 0
                        }
                        sparaList.append(data)
                        modelWindow.models.editData(modelBuilder.model, data, "StructuralParameters")
                    }
                }
            }

            ListView {
                anchors.top: spHeader.bottom
                anchors.bottom: parent.bottom
                width: parent.width

                model: sparaList

                delegate: sparadele
            }
        }
    }

// 功能区---------------------------------------------------------------------------------------
    ListModel {
        id: varList
    }

    ListModel {
        id: paraList
    }

    ListModel {
        id: sparaList
    }

    Component {
        id: vardele

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50

            signal setVar(int i)
            
            onSetVar: i => {
                let data = {
                    "Name": t1.text,
                    "Type": t2.currentRole,
                    "Unit": t3.text,
                    "Value": t4.text,
                    "Min": t5.text,
                    "Max": t6.text,
                    "Number": t7.text
                }
                varList[i] = data
                modelWindow.models.editData(modelBuilder.model, data, "Variables")
            }

            TextField {
                id: t1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 7
                placeholderText: Name
                placeholderTextColor: "black"
                onAccepted: {
                    setVar(index)
                }
            }
            ComboBox {
                id: t2
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                textRole: "name"
                valueRole: "name"
                width: (parent.width - 50) / 7
                currentIndex: 0
                model: varAndPara.dataTypes

                onAccepted: {
                    setVar(index)
                }
            }
            TextField {
                id: t3
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 7
                placeholderText: Unit
                placeholderTextColor: "black"
                onAccepted: {
                    setVar(index)
                }
            }
            TextField {
                id: t4
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 7
                placeholderText: Value
                placeholderTextColor: "black"
                onAccepted: {
                    setVar(index)
                }
            }
            TextField {
                id: t5
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 7
                placeholderText: Min
                placeholderTextColor: "black"
                onAccepted: {
                    setVar(index)
                }
            }
            TextField {
                id: t6
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 7
                placeholderText: Max
                placeholderTextColor: "black"
                onAccepted: {
                    setVar(index)
                }
            }
            TextField {
                id: t7
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 7
                placeholderText: Number
                placeholderTextColor: "black"
                onAccepted: {
                    setVar(index)
                }
            }
            Button {
                icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
                width: 50
                height: 50
                onClicked: {
                    modelWindow.models.editData(modelBuilder.model, {
                        "Name": Name
                    }, "Variables")
                    varList.remove(index)
                }
            }
        }
    }

    Component {
        id: paradele

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50

            signal setPara(int i)
            
            onSetPara: i => {
                let data = {
                    "Name": t1.text,
                    "Type": t2.currentRole,
                    "Unit": t3.text,
                    "Value": t4.text,
                    "Number": t5.text,
                    "Gui": t6.currentIndex,
                }
                paraList[i] = data
                modelWindow.models.editData(modelBuilder.model, data, "Parameters")
            }

            TextField {
                id: t1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 6
                placeholderText: Name
                placeholderTextColor: "black"
                onAccepted: {
                    setPara(index)
                }
            }
            ComboBox {
                id: t2
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                textRole: "name"
                valueRole: "name"
                width: (parent.width - 50) / 6
                currentIndex: 0
                model: varAndPara.dataTypes

                onAccepted: {
                    setPara(index)
                }
            }
            TextField {
                id: t3
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 6
                placeholderText: Unit
                placeholderTextColor: "black"
                onAccepted: {
                    setPara(index)
                }
            }
            TextField {
                id: t4
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 6
                placeholderText: Value
                placeholderTextColor: "black"
                onAccepted: {
                    setPara(index)
                }
            }
            TextField {
                id: t5
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 6
                placeholderText: Number
                placeholderTextColor: "black"
                onAccepted: {
                    setPara(index)
                }
            }
            ComboBox {
                id: t6
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 6
                model: ["Text", "CheckBox", "Switch"]
                currentIndex: Gui
                onAccepted: {
                    setPara(index)
                }
            }
            Button {
                icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
                width: 50
                height: 50
                onClicked: {
                    modelWindow.models.editData(modelBuilder.model, {
                        "Name": Name
                    }, "Parameters")
                    paraList.remove(index)
                }
            }
        }
    }

    Component {
        id: sparadele

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50

            signal setSPara(int i)
            
            onSetSPara: i => {
                let data = {
                    "Name": t1.text,
                    "Value": t2.text,
                    "Gui": t3.currentIndex,
                }
                sparaList[i] = data
                modelWindow.models.editData(modelBuilder.model, data, "StructuralParameters")
            }

            TextField {
                id: t1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 3
                placeholderText: Name
                placeholderTextColor: "black"
                onAccepted: {
                    setSPara(index)
                }
            }
            TextField {
                id: t2
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 3
                placeholderText: Value
                placeholderTextColor: "black"
                onAccepted: {
                    setSPara(index)
                }
            }
            ComboBox {
                id: t3
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width - 50) / 3
                model: ["Text", "CheckBox", "Switch"]
                currentIndex: Gui
                onAccepted: {
                    setSPara(index)
                }
            }
            Button {
                icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
                width: 50
                height: 50
                onClicked: {
                    modelWindow.models.editData(modelBuilder.model, {
                        "Name": Name
                    }, "StructuralParameters")
                    sparaList.remove(index)
                }
            }
        }
    }
}
