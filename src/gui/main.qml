import QtQuick 2.9
import QtQuick.Controls
import QtQuick.Window 2.2
import QtQuick.Dialogs 
import QtQuick.Layouts
import Qt.labs.platform as QLP
import "qrc:/mainmenu/MainMenu"

ApplicationWindow {
    id: mainWindow
    width: 1400
    height: 750
    visible: true
    title: "gAPHD ModelEditor 0.3.0"
    visibility: "Maximized"

    signal createAny(var name, int path)

    menuBar: Menus { id: menu }

    SplitView {
        anchors.fill: parent

        orientation: Qt.Horizontal

        Rectangle {
            id: projectList
            SplitView.minimumWidth: 200
            SplitView.preferredWidth: 200 
            height: parent.height

            color: "#D8BFD8"
        
            ScrollView {
                width: parent.width
                height: parent.height
                clip: true

                ScrollBar.vertical: ScrollBar {
                    interactive: true
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 10
                }

                FileTree {
                    id: tree
                    width: projectList.width
                    height: projectList.height
                }
            }
        }

        Rectangle {
            id: workSpace
            color: "white"
            SplitView.minimumWidth: 100
            SplitView.maximumWidth: mainWindow.width - 200
            SplitView.fillWidth: true

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
                        width: Math.min(300, workSpace.width / headers.count)

                        Row {
                            anchors.fill: parent

                            ToolButton {
                                width: parent.width - 50
                                icon.source: getIcon(type)
                                text: title
                                onClicked: {
                                    projectWindows.currentIndex = index + 1
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
                id: projectWindows
                anchors {
                    top: navigationBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                Repeater {
                    model: pages
                }
            }
        }
    }

// 功能区-------------------------------------------------------------------------
    
    ListModel {
        id: headers
    }

    Action {
        id: closeAction
        icon.source: "qrc:/icons/Icons/CodiconChromeClose.svg"
        onTriggered: source => {
            let index = source.pageIndex
            headers.remove(index - 1)
            if (index === projectWindows.currentIndex) {
                pages.remove(index)
                projectWindows.currentIndex = index - 1
            } else {
                pages.remove(index)
            }
        }
    }

    ObjectModel{
        id: pages

        Image {
            id: empty
            Layout.alignment: Qt.AlignCenter
            fillMode: Image.PreserveAspectFit
            Layout.fillHeight: true
            Layout.fillWidth: true

            source: "file:///D:/Work/leetcode/QtModelBuilder/logo.svg"
        }
    }

    onCreateAny:(name, path) => {
        let index = isPageExist(name, path)
        switch(path) {
        case 0:
            if (index > -1)
                projectWindows.currentIndex = index + 1
            else {
                var win = Qt.createComponent("qrc:/variable/Variables/Vars.qml")
                if (win.status !== Component.Ready){
                    console.debug(win.errorString())
                }
                var vars = win.createObject(workSpace,
                    {
                        "width": workSpace.width,
                        "height": workSpace.height,
                        "varTypes": Controler.getVarTypes(name)
                    }
                )
                headers.append({
                    "title": "变量类型编辑(" + name + ")",
                    "pname": name,
                    "type": 0
                })
                pages.append(vars)
                projectWindows.currentIndex = pages.count - 1
            }
            break
        case 1:
            if (index > -1)
                projectWindows.currentIndex = index + 1
            else {
                var win = Qt.createComponent("qrc:/connection/Connection/Conns.qml")
                if (win.status !== Component.Ready){
                    console.debug(win.errorString())
                }
                var conns = win.createObject(workSpace,
                    {
                        "width": workSpace.width,
                        "height": workSpace.height,
                        "typeList": Controler.getConnTypes(name),
                        "pname": name
                    }
                )
                headers.append({
                    "title": "连接类型编辑(" + name + ")",
                    "pname": name,
                    "type": 1
                })
                pages.append(conns)
                projectWindows.currentIndex = pages.count - 1
            }
            break
        case 2:
            if (index > -1)
                projectWindows.currentIndex = index + 1
            else {
                var win = Qt.createComponent("qrc:/model/Model/ModelList.qml")
                if (win.status !== Component.Ready){
                    console.debug(win.errorString())
                }
                var models = win.createObject(workSpace,
                    {
                        "width": workSpace.width,
                        "height": workSpace.height,
                        "models":  Controler.getModels(name),
                        "pname": name
                    }
                )
                headers.append({
                    "title": "模型编辑(" + name + ")",
                    "pname": name,
                    "type": 2
                })
                pages.append(models)
                projectWindows.currentIndex = pages.count - 1
            }
            break
        case 3:
            if (index > -1)
                projectWindows.currentIndex = index + 1
            else {
                var win = Qt.createComponent("qrc:/system/System/ProcessList.qml")
                if (win.status !== Component.Ready){
                    console.debug(win.errorString())
                }
                var systems = win.createObject(workSpace,
                    {
                        "width": workSpace.width,
                        "height": workSpace.height,
                    }
                )
                headers.append({
                    "title": "流程编辑(" + name + ")",
                    "pname": name,
                    "type": 3
                })
                pages.append(systems)
                projectWindows.currentIndex = pages.count - 1
            }
            break
        }
    }

    Loader {
        id: loader
        active: false // 初始时不激活
        anchors.fill: parent
        source: "" // 设置子窗口的源文件

        property string pname: ""
        property int type: 0

        onLoaded: {
            loader.item.closing.connect(handleClosed)
            switch(loader.type) {
            case 3:
                loader.item.pname = loader.pname
                var arr = Controler.getSystems(loader.pname)
                if (arr.length !== 0) {
                    loader.item.systems.append(...arr)
                }
            }
        }
    }

    Loader {
        id: menuLoader
        active: false // 初始时不激活
        anchors.fill: parent
        source: "" // 设置子窗口的源文件

        onLoaded: {
            menuLoader.item.closing.connect(handleClosed)
        }
    }

    QLP.FolderDialog {
        id: saveFile
        title: "选择导出文件夹"
        visible: false
        onAccepted: {
            Controler.saveProject(folder)
            mainWindow.close()
        }
        onRejected: {
            msgBox.source = ""
            mainWindow.closeFlag = false
            mainWindow.closeType = 0
        }
    }

    Connections {
        target: menu
        function onOpenProject() {
            loadFile.open()
        }
    }

   FileDialog {
        id: loadFile
        title: "选择导入项目"
        visible: false
        onAccepted: {
            let name = selectedFile.toString().split('/').pop().split('.').shift()
            tree.createItem(name)
            Controler.loadProject(selectedFile)
        }
    }

    Loader {
        id: msgBox
        active: false 
        anchors.fill: parent
        source: "/mainmenu/MainMenu/MyMessage.qml" 

        onLoaded: {
            msgBox.item.closing.connect(closeProject)
        }
    }


    property bool closeFlag: false
    property int closeType: 0

    onClosing: close => {
        // 此处程序会异步执行,因而有些复杂
        close.accepted = mainWindow.closeFlag
        if (!mainWindow.closeFlag) {
            msgBox.source = "/mainmenu/MainMenu/MyMessage.qml" 
            msgBox.active = true
        }
    }

    function closeProject() {
        switch (closeType) {
        case 1:
            mainWindow.closeFlag = true
            saveFile.open()
            break;
        case 2:
            mainWindow.closeFlag = false
            msgBox.source = ""
            msgBox.active = false
            break;
        case 3:
            mainWindow.closeFlag = true
            mainWindow.close()
            break;
        }
    }

    // 此函数释放子窗口资源,使其关闭后还可打开
    function handleClosed() {
        loader.source = ""
        loader.pname = ""
        // 此行尤为重要,如不设置false,则Loader不会瞬时重置
        loader.active = false
        menuLoader.source = ""
        menuLoader.active = false
    }
    function isPageExist(pname, type) {
        for (let i = 0; i < headers.count; ++i) {
            let p = headers.get(i)
            if (p.pname === pname && p.type === type)
                return i
        }
        return -1
    }
    function getIcon(type) {
        switch(type){
        case 0:
            return "qrc:/icons/Icons/CarbonValueVariable.svg"
        case 1:
            return "qrc:/icons/Icons/CarbonConnect.svg"
        case 2:
            return "qrc:/icons/Icons/CarbonModelAlt.svg"
        case 3:
            return "qrc:/icons/Icons/CarbonModelBuilder.svg"
        }
    }
}
