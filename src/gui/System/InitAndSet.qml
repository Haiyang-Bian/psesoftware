import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.6
import QtQuick.Window

Window {
    visible: true
    width: 800
    height: 600
    title: "初值输入与仿真参数设置"

    TabBar {
        id: tabBar
        Layout.alignment: Qt.AlignBottom
        currentIndex: stack.currentIndex

        TabButton {
            id: t1
            text: "初值输入"
            // 当点击时，切换到对应的页面
            width: 200

            background: Rectangle {
                color: "transparent"
                border.color: "black"
            }
            onClicked: {
                stack.currentIndex = 0
            }
        }
        TabButton {
            id: t2
            text: "仿真参数设置"
            // 当点击时，切换到对应的页面
            width: 200

            background: Rectangle {
                // 设置背景色和边框
                color: "transparent" // 背景色
                border.color: "black"
            }
            onClicked: {
                stack.currentIndex = 1
            }
        }
        TabButton {
            id: t3
            text: "结果图像"
            // 当点击时，切换到对应的页面
            width: 200

            background: Rectangle {
                // 设置背景色和边框
                color: "transparent" // 背景色
                border.color: "black"
            }
            onClicked: {
                stack.currentIndex = 2
            }
        }
    }

    StackLayout {
        id: stack
        anchors {
            top: tabBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 2
        }

        // 初值输入区
        Rectangle {
            id: init
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.5

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                    // 输入框的标签和数量由模型决定
                Rectangle {
                    Layout.topMargin: 60
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: "black"

                    ScrollView {
                        id: initialValues
                        anchors.fill: parent
                        clip: true

                        ListView {
                            id: initVal
                            clip: true
                            anchors.fill: parent

                            model: inits

                            delegate: initDel
                        }
                    }
                }

                Button {
                    text: "确认"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter

                    onClicked: {
                        stack.currentIndex = 1
                    }
                }
            }
        }

        // 仿真参数设置区
        Rectangle {
            id: simulationParameters
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.5

            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    // 时域设置
                    id: settings
                    border.color: "black"
                    Layout.fillWidth: true
                    Layout.topMargin: 60
                    Layout.preferredHeight: parent.height * 0.4
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50

                            spacing: 20

                            Label {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 50
                                text: "仿真时域设置:"
                            }

                            TextField {
                                id: l
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 50
                                placeholderText: "时域下限"
                            }
                            TextField {
                                id: u
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 50
                                placeholderText: "时域上限"
                            }
                        }

                        RowLayout {
                            // 求解器选择
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50

                            spacing: 20

                            Label {
                                text: "选择求解器:"
                            }

                            ComboBox {
                                // Combox内容由模型决定
                                // 示例:
                                model: ["Tsit5", "求解器2", "求解器3"]
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.5 - 60

                    border.color: "black"

                    // 变量选择区
                    GridView {
                        visible: true
                        anchors.fill: parent
                        anchors.topMargin: 20
                        anchors.leftMargin: 20
                        clip: true

                        cellHeight: 50
                        cellWidth: 350

                        model: back

                        delegate: Rectangle {
                            width: 350
                            height: 50
                            Row {
                                anchors.fill: parent
                                spacing: 20
                                Label {
                                    text: VarName
                                    width: 150
                                    height: 50
                                }

                                CheckBox {
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 50

                                    Component.onCompleted: checked = Selected

                                    onCheckedChanged: {
                                        Selected = checked
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    text: "开始计算"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignHCenter

                    onClicked: {
                        var view = []
                        for (let i = 0; i < back.count; ++i) {
                            if (back.get(i).Selected){
                                view.push(back.get(i).VarName)
                            }
                        }
                        var initVals = {}
                        for (let i = 0; i < inits.count; ++i) {
                            initVals[inits.get(i).VarName] = inits.get(i).Value
                        }
                        Controler.simulation({
                            "InitialConditions": initVals,
                            "TimeSpan": [l.text, u.text],
                            "BackValues": view
                        })
                    }
                }
            }
        }

        Rectangle {
            ChartView {
                id: results
                
                anchors.topMargin: 60
                anchors.fill: parent
                antialiasing: true
                theme: ChartView.ChartThemeBlueNcs

                ValuesAxis {
                    id: xZhou
                    min: Number(l.text)
                    max: Number(u.text)
                }

                ValuesAxis {
                    id: yZhou
                    min: -20
                    max: 20
                }
            }
        }
    }

    Connections{
        target: Controler

        function onSimulationEnd(result){
            var keys = Object.keys(result);
            for (var line of keys) {
                if (line !== "t") {
                    let series = results.createSeries(ChartView.SeriesTypeLine, line);
                    series.axisX = xZhou
                    series.axisY = yZhou

                    for (let i = 0; i < result["t"].length; ++i) {
                        series.append(result["t"][i], result[line][i])
                    }
                }
            }
        }
    }


    ListModel {
        id: inits
    }

    ListModel {
        id: back
    }

    Component {
        id: initDel

        RowLayout {
            width: 700
            height: 50

            Label {
                Layout.leftMargin: 20
                text: VarName
            }

            TextField {
                placeholderText: "请输入" + VarName + "的初值!"

                onAccepted: {
                    Value = text
                }
            }
        }
    }
    
    Component.onCompleted: {
        var info = Controler.systemInfo(sysWindow.pname, sysWindow.sysname)
        info.States.forEach(s=>{
            inits.append({
                "VarName": s,
                "Value": "0"
            })
        })
        info.Variables.forEach(v=>{
            back.append({
                "VarName": v,
                "Selected": false
            })
        })
    }
}
