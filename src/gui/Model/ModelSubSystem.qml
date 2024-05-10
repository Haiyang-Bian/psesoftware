import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window
import "qrc:/dndkit/DndComp"

Rectangle {
	id: subSystemEditor

	DropComponent {
		id: workSpace
		anchors.fill: parent
        dndControler: modelWindow.models.editSubSystem(modelBuilder.model)
	}

	Component.onCompleted: {
        setPorts()
    }

    ObjectModel {
        id: ports
    }

    function hasPort(name) {
        for (let i = 0; i < ports.count; ++i) {
            if (name === ports.get(i).setname){
                return i + 1
            }
        }
        return false
    }

    function setPorts() {
        let arr = modelWindow.models.getData(modelBuilder.model, "Ports")
        for (let i = 0;i < arr.length; ++i){
            let comp = Qt.createComponent("qrc:/dndkit/DndComp/DragComponent.qml")
            if (comp.status !== Component.Ready){
                console.debug(comp.errorString())
            }
            let index = hasPort(arr[i].Name)
            if (!index) {
                let obj = comp.createObject(workSpace,
                    {
                        "dnd": workSpace.dndControler,
                        "setname": arr[i].Name,
                        "x": 20 + 100 * i,
                        "y": 20,
                        "supportedActions": Qt.MoveAction,
                        "dragType": Drag.Internal,
                        "isDropped": true,
                        "isPort": true,
                        "hdata": [arr[i]],
                        "width": 80,
                        "height": 80
                    }
                )
                ports.append(obj)
            } else {
                let obj = comp.createObject(workSpace,
                    {
                        "setname": arr[i].Name,
                        "x": ports.get(index - 1).x,
                        "y": ports.get(index - 1).y,
                        "supportedActions": Qt.MoveAction,
                        "dragType": Drag.Internal,
                        "isDropped": true,
                        "isPort": true,
                        "hdata": [arr[i]],
                        "width": 80,
                        "height": 80
                    }
                )
                ports.remove(index - 1)
                ports.insert(obj, index - 1)
            }
        }
    }
}
