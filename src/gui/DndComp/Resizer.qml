import QtQuick
import QtQuick.Controls

Item {
	property bool resize: leftSizer.hovered || 
            topSizer.hovered || 
            bottomSizer.hovered || 
            rightSizer.hovered ||
            ltSizer.hovered ||
            rbSizer.hovered ||
            trSizer.hovered ||
            blSizer.hovered
    property var realParent: undefined

    signal sizeChanged()

	// 改变大小(四个边)
    Rectangle {
        id: top
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.top
        }
        height: 20
        opacity: 0.0

        property var h0: 0
        property var y0: 0

        Component.onCompleted: {
            h0 = realParent.height
            y0 = realParent.y
        }

        HoverHandler {
            id: topSizer
            cursorShape: Qt.SizeVerCursor
        }

        DragHandler {
            xAxis.enabled: false
            yAxis.maximum: 0
            onActiveChanged: {
                if (active) {
                    top.h0 = realParent.height
                }
                else {
                    if (realParent.height < 80) {
                        realParent.y = top.y0
                        top.h0 = 80
                        realParent.height = 80
                    }
                    else {
                        realParent.height -= realParent.height % 20
                        top.h0 = realParent.height 
                        realParent.y -= realParent.y % 20
                        top.y0 = realParent.y
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.height = top.h0 - activeTranslation.y
                realParent.y = top.y0 + activeTranslation.y
            }
        }
    }

    Rectangle {
        id: right
        anchors {
            left: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 20
        opacity: 0.0

        property var w0: 0

        Component.onCompleted: {
            w0 = realParent.width
        }

        HoverHandler {
            id: rightSizer
            cursorShape: Qt.SizeHorCursor
        }

        DragHandler {
            yAxis.enabled: false
            xAxis.minimum: 80
            onActiveChanged: {
                if (active) {
                    right.w0 = realParent.width
                }
                else{
                    if (realParent.width < 80) {
                        right.w0 = 80
                        realParent.width = 80
                    }
                    else {
                        realParent.width -= realParent.width % 20
                        right.w0 = realParent.width
                        right.x = realParent.width
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.width = right.w0 + activeTranslation.x
            }
        }
    }

    Rectangle {
        id: bottom
        anchors {
            left: parent.left
            right: parent.right
            top: parent.bottom
        }
        height: 20
        opacity: 0.0

        property var h0: 0

        Component.onCompleted: {
            h0 = realParent.height
        }

        HoverHandler {
            id: bottomSizer
            cursorShape: Qt.SizeVerCursor
        }

        DragHandler {
            xAxis.enabled: false
            yAxis.minimum: 80
            onActiveChanged: {
                if (active) {
                    bottom.h0 = realParent.height
                }
                else {
                    if (realParent.height < 80) {
                        bottom.h0 = 80
                        realParent.height = 80
                    }
                    else {
                        realParent.height -= realParent.height % 20
                        bottom.h0 = realParent.height
                        bottom.y = realParent.height
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.height = bottom.h0 + activeTranslation.y
            }
        }
    }

    Rectangle {
        id: left
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.left
        }
        width: 20
        opacity: 0.0

        property var w0: 0
        property var x0: 0

        Component.onCompleted: {
            w0 = realParent.width
            x0 = realParent.x
        }

        HoverHandler {
            id: leftSizer
            cursorShape: Qt.SizeHorCursor
        }

        DragHandler {
            yAxis.enabled: false
            xAxis.maximum: 0
            onActiveChanged: {
                if (active) {
                    left.w0 = realParent.width
                    left.x0 = realParent.x
                }
                else {
                    if (realParent.width < 80) {
                        realParent.x = left.x0
                        left.w0 = 80
                        realParent.width = 80
                    }
                    else {
                        realParent.width -= realParent.width % 20
                        left.w0 = realParent.width
                        realParent.x -= realParent.x % 20
                        left.x0 = realParent.x
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.width = left.w0 - activeTranslation.x
                realParent.x = left.x0 + activeTranslation.x
            }
        }
    }

    // 四个角
    Rectangle {
        id: leftAndTop
        anchors {
            right: parent.left
            bottom: parent.top
        }
        height: 20
        width: 20
        opacity: 0.0

        property var k: 1
        property var w0: 0
        property var x0: 0
        property var y0: 0

        HoverHandler {
            id: ltSizer
            cursorShape: Qt.SizeFDiagCursor
        }

        DragHandler {
            xAxis.maximum: 0
            yAxis.maximum: 0
            onActiveChanged: {
                if (active) {
                    leftAndTop.x0 = realParent.x
                    leftAndTop.y0 = realParent.y
                    leftAndTop.w0 = realParent.width
                    leftAndTop.k = realParent.height / realParent.width
                }
                else {
                    if (realParent.height < 80) {
                        realParent.y = leftAndTop.y0
                        realParent.height = 80
                    }
                    else {
                        realParent.height -= realParent.height % 20
                        realParent.y -= realParent.y % 20
                        leftAndTop.y0 = realParent.y
                    }
                    if (realParent.width < 80){
                        realParent.x = leftAndTop.x0
                        leftAndTop.w0 = 80
                        realParent.width = 80
                    }else {
                        realParent.width -= realParent.width % 20
                        leftAndTop.w0 = realParent.width
                        realParent.x -= realParent.x % 20
                        leftAndTop.x0 = realParent.x
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.width = leftAndTop.w0 - activeTranslation.x
                realParent.height = realParent.width * leftAndTop.k
                realParent.x = leftAndTop.x0 + activeTranslation.x
                realParent.y = leftAndTop.y0 + leftAndTop.k * activeTranslation.x
            }
        }
    }

    Rectangle {
        id: rightAndBottom
        anchors {
            left: parent.right
            top: parent.bottom
        }
        height: 20
        width: 20
        opacity: 0.0

        property var w0: 0
        property var k: 1

        HoverHandler {
            id: rbSizer
            cursorShape: Qt.SizeFDiagCursor
        }

        DragHandler {
            xAxis.minimum: 80
            yAxis.minimum: 80
            onActiveChanged: {
                if (active) {
                    rightAndBottom.w0 = realParent.width
                    rightAndBottom.k = realParent.height / realParent.width
                }
                else {
                    if (realParent.height < 80) {
                        realParent.height = 80
                    }
                    else {
                        realParent.height -= realParent.height % 20
                    }
                    if (realParent.width < 80){
                        rightAndBottom.w0 = 80
                        realParent.width = 80
                    }else {
                        realParent.width -= realParent.width % 20
                        rightAndBottom.w0 = realParent.width
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.width = rightAndBottom.w0 + activeTranslation.x
                realParent.height = realParent.width * rightAndBottom.k
            }
        }
    }

    Rectangle {
        id: topAndRight
        anchors {
            left: parent.right
            bottom: parent.top
        }
        height: 20
        width: 20
        opacity: 0.0

        property var k: 1
        property var w0: 0
        property var y0: 0

        HoverHandler {
            id: trSizer
            cursorShape: Qt.SizeBDiagCursor
        }

        DragHandler {
            xAxis.minimum: 80
            yAxis.maximum: 0
            onActiveChanged: {
                if (active) {
                    topAndRight.y0 = realParent.y
                    topAndRight.w0 = realParent.width
                    topAndRight.k = realParent.height / realParent.width
                }
                else {
                    if (realParent.height < 80) {
                        realParent.y = topAndRight.y0
                        realParent.height = 80
                    }
                    else {
                        realParent.height -= realParent.height % 20
                        realParent.y -= realParent.y % 20
                        topAndRight.y0 = realParent.y
                    }
                    if (realParent.width < 80){
                        topAndRight.w0 = 80
                        realParent.width = 80
                    }else {
                        realParent.width -= realParent.width % 20
                        topAndRight.w0 = realParent.width
                        realParent.x -= realParent.x % 20
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.width = topAndRight.w0 + activeTranslation.x
                realParent.height = realParent.width * topAndRight.k
                realParent.y = topAndRight.y0 - topAndRight.k * activeTranslation.x
            }
        }
    }

    Rectangle {
        id: bottomAndLeft
        anchors {
            right: parent.left
            top: parent.bottom
        }
        height: 20
        width: 20
        opacity: 0.0

        property var w0: 0
        property var k: 1
        property var x0: 0

        HoverHandler {
            id: blSizer
            cursorShape: Qt.SizeBDiagCursor
        }

        DragHandler {
            xAxis.minimum: 0
            yAxis.minimum: 80
            onActiveChanged: {
                if (active) {
                    bottomAndLeft.w0 = realParent.width
                    bottomAndLeft.x0 = realParent.x
                    bottomAndLeft.k = realParent.height / realParent.width
                }
                else {
                    if (realParent.height < 80) {
                        realParent.height = 80
                    }
                    else {
                        realParent.height -= realParent.height % 20
                    }
                    if (realParent.width < 80){
                        bottomAndLeft.w0 = 80
                        bottomAndLeft.x = bottomAndLeft.x0
                        realParent.width = 80
                    }else {
                        realParent.width -= realParent.width % 20
                        bottomAndLeft.w0 = realParent.width
                    }
                    sizeChanged()
                }
            }

            onTranslationChanged: {
                realParent.width = bottomAndLeft.w0 - activeTranslation.x
                realParent.height = realParent.width * bottomAndLeft.k
                realParent.x = bottomAndLeft.x0 + activeTranslation.x
            }
        }
    }
}
