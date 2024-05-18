import QtQuick
import QtQuick.Controls
import Ai4Energy 1.0

DropArea {
    id: dragArea

    width: 500
    height: 500

    property bool isSubSystem: false
    property int space: 20
    property var dndControler: undefined

    Connections {
        target: dndControler
        function onMoveEnd() {
            dragArea.bufferLine = []
            bufferCanvas.requestPaint()
            lineCanvas.requestPaint()
        }
        function onRmNode() {
            lineCanvas.requestPaint()
        }
    }

    onDropped: drop => {
        if (drop.source.Drag.supportedActions === Qt.CopyAction && drop.source.type === "Component") {
            let x = drop.x - drop.source.width / 2
            x -= x % space
            let y = drop.y - drop.source.height / 2
            y -= y % space
            var comp = Qt.createComponent("DragComponent.qml")
            var obj = comp.createObject(dragArea,
                {
                    "dnd": dndControler,
                    "setname": "node_" + prosessWindow.nodeId,
                    "x": x,
                    "y": y,
                    "supportedActions": Qt.MoveAction,
                    "dragType": Drag.Internal,
                    "isDropped": true,
                    "hdata": drop.source.hdata,
                    "compType": drop.source.compType,
                    "image": drop.source.image,
                    "paras": drop.source.paras,
                    "width": drop.source.width,
                    "height": drop.source.height
                }
            )
            dndControler.createNode({
                "Name": "node_" + prosessWindow.nodeId,
                "X": x,
                "Y": y,
                "Type": drop.source.compType,
                "Handlers": drop.source.hdata,
                "Width": drop.source.width,
                "Height": drop.source.height
            })
            prosessWindow.nodeId += 1
        }
        drop.acceptProposedAction();
        drop.accepted = true;
    }

    Rectangle {
        id: dropRectangle

        anchors.fill: parent
        color: "white"
    }

    property var line: {
        start: [];
        end: []
    }
    property var bufferLine: []

    onPositionChanged: drag => {
        if (drag.source.type === "Node") {
            let s = drag.source.parent.parent.parent.setname
            let sh = drag.source.parent.parent.hname
            dragArea.line.start = dndControler.getPosition(s, sh)
            dragArea.line.end = [drag.x, drag.y]
            bufferCanvas.requestPaint()
        }
        if (drag.source.type === "Component") {
            let x = drag.x - drag.source.width / 2;
            let y = drag.y - drag.source.height / 2;
            bufferLine = dndControler.moveNode(drag.source.setname, x, y)
            if (bufferLine.length > 0)
                bufferCanvas.requestPaint()
        }
    }

    Canvas {
        id: lineCanvas
        anchors.fill: parent
        z: 30
        opacity: 0.9
        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, lineCanvas.width, lineCanvas.height)
            ctx.beginPath();
            movePaint(ctx)
            ctx.stroke();
        }
    }
    Canvas {
        id: backCanvas
        anchors.fill: parent
        z: 0
        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, backCanvas.width, backCanvas.height)
            grid(ctx)
            ctx.stroke();
        }
    }
    Canvas {
        id: bufferCanvas
        anchors.fill: parent
        z: 10
        opacity: 0.9
        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, bufferCanvas.width, bufferCanvas.height)
            connectPaint(ctx)
            bufferPaint(ctx)
            ctx.stroke();
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton | Qt.LeftButton
    
        onSingleTapped: (eventPoint, button) => {
            if (button === Qt.RightButton) {
                let id = dndControler.getEdgeId(eventPoint.position.x, eventPoint.position.y)
                if (id !== -1){
                    contextMenu.edgeId = id
                    contextMenu.popup(eventPoint.position);
                }
            } else {
                if (dndControler.selectedEdge(eventPoint.position.x, eventPoint.position.y)) {
                    lineCanvas.requestPaint()
                }
            }
        }
    }

    Menu {
        id: contextMenu

        property int edgeId: -1

        MenuItem { 
            text: "删除"; 
            onTriggered: { 
                //dndControler.removeEdge(contextMenu.edgeId)
                lineCanvas.requestPaint()
            } 
        }

        MenuItem { text: "选项2"; onTriggered: { /* 处理选项2 */ } }
        MenuItem { text: "选项3"; onTriggered: { /* 处理选项3 */ } }
    }

    Component.onCompleted: {
        let comps = dndControler.getNodes()
        for (let c of comps) {
             let comp = Qt.createComponent("DragComponent.qml")
             let obj = comp.createObject(dragArea,
                 {
                     "dnd": dndControler,
                     "setname": c.Name,
                     "x": c.X,
                     "y": c.Y,
                     "supportedActions": Qt.MoveAction,
                     "dragType": Drag.Internal,
                     "isDropped": true,
                     "hdata": c.Handlers,
                     "compType": c.Type,
                     "image": "",
                     "paras": [],
                     "width": c.Width,
                     "height": c.Height
                 }
             )
        }
    }

    function connectPaint(ctx){
        if (dragArea.line.start !== undefined) {
            ctx.beginPath();
            ctx.setLineDash([5, 15]);
            ctx.lineWidth = 3
            ctx.moveTo(dragArea.line.start[0], dragArea.line.start[1])
            ctx.lineTo(dragArea.line.end[0],dragArea.line.end[1])
            dragArea.line.start = []
            dragArea.line.end = []
        }
    }

    function bufferPaint(ctx) {
        if (bufferLine.length > 0){
            ctx.beginPath();
            ctx.setLineDash([]);
            ctx.lineWidth = 3
            for (let p of bufferLine){
                ctx.moveTo(p.Start[0], p.Start[1])
                ctx.lineTo(p.End[0], p.End[1])
            }
            bufferLine = []
        }
    }

    function movePaint(ctx) {
        let paths = dndControler.getEdges()
        if (paths.length > 0) {
            for (let path of paths) {
                pathPaint(ctx, path)
            }
        }
    }

    function pathPaint(ctx, path) {
        ctx.beginPath();
        ctx.lineWidth = 3
        ctx.setLineDash([])
        ctx.moveTo(path[0], path[0])
        for (let i = 0;i < path.length; i++){
            ctx.lineTo(path[i].X,path[i].Y)
        }
        ctx.stroke();
    }

    function grid(ctx){
        var rows = height / space;
        var columns = width / space;
        for (let i = 0; i < rows; i++) {
            for (let j = 0; j < columns; j++) {
                let x = j * space;
                let y = i * space;
                ctx.fillText("*", x, y)
            }
        }
        ctx.fillStyle = "black";
        ctx.font = "18px Arial"; 
    }
}
