import QtQuick
import Ai4Energy 1.0

DropArea {
    id: handle

    width: 20
    height: 20

    property string hname: ""
    property DndControler dnd: undefined

    onDropped: drop => {
        let s = drop.source.parent.parent.parent.setname
        let sh = drop.source.parent.parent.hname
        dnd.creatEdge({
            "Id": prosessWindow.edgeId,
            "Source": s,
            "Target": parent.setname,
            "SourceHandler": sh,
            "TargetHandler": hname
        })
        prosessWindow.edgeId += 1
        lineCanvas.requestPaint()
        bufferCanvas.requestPaint()
        drop.acceptProposedAction();
        drop.accepted = true;
    }

    Node {
        anchors.centerIn: handle
        z: 20
    }

    Rectangle {
        id: dropRectangle

        anchors.fill: parent
        color: "blue"
    }
}
