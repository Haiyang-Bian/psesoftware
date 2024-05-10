import QtQuick 2.3
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: materialEditor
    border.color: "black"
    border.width: 2

    property string propsName: ""

    signal setMedia(var data)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 3

        RowLayout {
            Text {
                text: qsTr("工质名称:")
            }

            TextField {
                placeholderText: propsName

                onAccepted: {
                    for (let i = 0; i < fluids.count; ++i){
                        if (fluids.get(i).name === propsName) {
                            fluids.get(i).name = text
                            break
                        }
                    }
                    for (let i = 0; i < headers.count; ++i) {
                        if (headers.get(i).name === propsName) {
                            headers.get(i).name = text
                            headers.get(i).title = "工质编辑(" + text + ")"
                            break
                        }
                    }
                }
            }
        }

        RowLayout {
            Text {
                text: qsTr("物质列表")
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: materialEditor.height * 2 / 3
            Layout.preferredWidth: materialEditor.width

            Layout.margins: 2
            border.color: "black"
            border.width: 2

            Rectangle {
                id: pureAndPseudoPureSubstances
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: 5
                }

                width: materialEditor.width / 2

                ListView {
                    id: substances
                    anchors.fill: parent

                    clip: true

                    model: cpList

                    delegate: Rectangle {
                        width: materialEditor.width / 2
                        height: 30
                        border {
                            color: "black"
                            width: 2
                        }
                        RowLayout {
                            anchors.fill: parent
                            Text {
                                Layout.fillWidth: true
                                text: name
                            }

                            Button {
                                icon.source: "qrc:/icons/Icons/CodiconDiffAdded.svg"
                                onClicked: {
                                    props.append({
                                        "name": name,
                                        "sindex": index,
                                    })
                                    cpList.remove(index)
                                    setMedia({
                                        "Name": propsName,
                                        "Propertys": getData()
                                    })
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: selectedList

                anchors {
                    left: pureAndPseudoPureSubstances.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    margins: 5
                }

                border {
                    color: "black"
                    width: 2
                }

                ListView {
                    anchors.fill: parent
                    model: props

                    delegate: Rectangle {
                        width: selectedList.width
                        height: 30
                        border {
                            color: "black"
                            width: 2
                        }

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                Layout.fillWidth: true
                                text: name
                            }
                            Button {
                                icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
                                onClicked: {
                                    cpList.insert(sindex, { 
                                        "name": name, 
                                        "sindex": sindex
                                    })
                                    props.remove(index)
                                    setMedia({
                                        "Name": propsName,
                                        "Propertys": getData()
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: props
    }

    ListModel {
        id: cpList
    }

    function getData(){
        let data = []
        for (let i = 0;i < cpList.count; ++i){
            data.push(props.get(i).name)
        }
        return data
    }

    Component.onCompleted: {
        for (let i = 0; i < coolPropList.length; ++i)
            cpList.append({ "name": coolPropList[i], "sindex": i })
    }

    property var coolPropList: [
                        "1-Butene",
                        "Acetone",
                        "Ammonia",
                        "Argon",
                        "Benzene",
                        "CarbonDioxide",
                        "CarbonMonoxide",
                        "CarbonylSulfide",
                        "CycloHexane",
                        "CycloPropane",
                        "Cyclopentane",
                        "D4",
                        "D5",
                        "D6",
                        "Deuterium",
                        "Dichloroethane",
                        "DiethylEther",
                        "DimethylCarbonate",
                        "DimethylEther",
                        "Ethane",
                        "Ethanol",
                        "EthylBenzene",
                        "Ethylene",
                        "EthyleneOxide",
                        "Fluorine",
                        "HFE143m",
                        "HeavyWater",
                        "Helium",
                        "Hydrogen",
                        "HydrogenChloride",
                        "HydrogenSulfide",
                        "IsoButane",
                        "IsoButene",
                        "Isohexane",
                        "Isopentane",
                        "Krypton",
                        "MD2M",
                        "MD3M",
                        "MD4M",
                        "MDM",
                        "MM",
                        "Methane",
                        "Methanol",
                        "MethylLinoleate",
                        "MethylLinolenate",
                        "MethylOleate",
                        "MethylPalmitate",
                        "MethylStearate",
                        "Neon",
                        "Neopentane",
                        "Nitrogen",
                        "NitrousOxide",
                        "Novec649",
                        "OrthoDeuterium",
                        "OrthoHydrogen",
                        "Oxygen",
                        "ParaDeuterium",
                        "ParaHydrogen",
                        "Propylene",
                        "Propyne",
                        "R11",
                        "R113",
                        "R114",
                        "R115",
                        "R116",
                        "R12",
                        "R123",
                        "R1233zd(E)",
                        "R1234yf",
                        "R1234ze(E)",
                        "R1234ze(Z)",
                        "R124",
                        "R1243zf",
                        "R125",
                        "R13",
                        "R134a",
                        "R13I1",
                        "R14",
                        "R141b",
                        "R142b",
                        "R143a",
                        "R152A",
                        "R161",
                        "R21",
                        "R218",
                        "R22",
                        "R227EA",
                        "R23",
                        "R236EA",
                        "R236FA",
                        "R245ca",
                        "R245fa",
                        "R32",
                        "R365MFC",
                        "R40",
                        "R404A",
                        "R407C",
                        "R41",
                        "R410A",
                        "R507A",
                        "RC318",
                        "SES36",
                        "SulfurDioxide",
                        "SulfurHexafluoride",
                        "Toluene",
                        "Water",
                        "Xenon",
                        "cis-2-Butene",
                        "m-Xylene",
                        "n-Butane",
                        "n-Decane",
                        "n-Dodecane",
                        "n-Heptane",
                        "n-Hexane",
                        "n-Nonane",
                        "n-Octane",
                        "n-Pentane",
                        "n-Propane",
                        "n-Undecane",
                        "o-Xylene",
                        "p-Xylene",
                        "trans-2-Butene"
                    ]
}
