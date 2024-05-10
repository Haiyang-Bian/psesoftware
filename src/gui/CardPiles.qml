import QtQuick 2.3
import QtQuick.Layouts

Rectangle {
    anchors.fill: parent

    signal createCard(string url, var init, var header)

    onCreateCard: (url, init, header) => {
        let index = 0
        if (index > -1)
                cardPiles.currentIndex = index
        else {
            var win = Qt.createComponent(url)
            if (win.status !== Component.Ready){
                console.debug(win.errorString())
            }
            var card = win.createObject(cardPiles, init)
            headers.append(header)
            cards.append(card)
            cardPiles.currentIndex = pages.count - 1
        }
    }

    // 卡片标签
    Row {
        id: navigationBar
        anchors {
            right: parent.right
            left: parent.left
            top: parent.top
        }

        height: 50

        Repeater {
            model: headers

            delegate: ToolBar { 
                anchors { 
                        top: parent.top
                        bottom: parent.bottom
                    }
                width: Math.min(300, parent.width / headers.count)

                Row {
                    anchors.fill: parent

                    ToolButton {
                        width: parent.width - 50
                        icon.source: getIcon(type)
                        text: title
                        onClicked: {
                            cardPiles.currentIndex = index
                        }
                    }

                    ToolButton {
                        width: 50
                        property int pageIndex: index + 1
                        action: closeAction
                    }
                }
            }
        }
    }

    StackLayout {
        id: cardPiles
        anchors {
            top: navigationBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Repeater {
            model: cards
        }
    }

// 功能区-------------------------------------------------------------------------
    
    ListModel {
        id: headers
    }

    ObjectModel{
        id: cards
    }

    function isPageExist(pname, type) {
        for (let i = 0; i < headers.count; ++i) {
            let p = headers.get(i)
            if (p.pname === pname && p.type === type)
                return i
        }
        return -1
    }
}
