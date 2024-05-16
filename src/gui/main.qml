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
    title: "gAPHD ModelEditor 0.4.0"
    visibility: "Maximized"

    menuBar: Menus { id: menu }

    SplitView {
        anchors.fill: parent

        orientation: Qt.Horizontal

        Rectangle {
            id: projectList

            SplitView.minimumWidth: 200
            SplitView.preferredWidth: 200 
            height: parent.height
            border {
                color: "black"
                width: 1
            }
            color: "white"

            Rectangle {
                id: titleBar
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 50
                color: "#B266FF"
                border {
                    color: "black"
                    width: 2
                }
                Text {
                    anchors.centerIn: parent
                    text: "项目树"
                }
            }
        
            ScrollView {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    top: titleBar.bottom
                }
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
                    anchors.fill: parent
                }
            }
        }

        Rectangle {
            id: workSpace
            color: "white"
            border {
                color: "black"
                width: 1
            }
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

            source: "qrc:/logo/Logo/logo.svg"
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
            loader.item.closing.connect(()=>{
                item.source = ""
                item.active = false
            })
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
            if (item.creatProject !== undefined){
                item.creatProject.connect(name => {
                    tree.createItem(name)
                    Controler.creatProject(name)
                })
            }
            if (item.updateLibs !== undefined){
                item.updateLibs.connect(arr => {
                    Controler.selectLibs(arr)
                })
            }
            menuLoader.item.closing.connect(()=>{
                menuLoader.source = ""
                menuLoader.active = false
            })
        }
    }

    QLP.FolderDialog {
        id: saveFile
        title: "选择导出文件夹"
        visible: false
        onAccepted: {
            Controler.saveProject(folder)
            if (mainWindow.closeFlag)
                mainWindow.close()
        }
        onRejected: {
            msgBox.source = ""
            mainWindow.closeFlag = false
        }
    }

    Connections {
        target: tree
        function onEditItem(name, type) {
            let path = type
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
    }

    Connections {
        target: menu
        function onCreatProject() {
            menuLoader.source = "qrc:/mainmenu/MainMenu/ProjectCreate.qml"
            menuLoader.active = true
        }
        function onOpenProject() {
            loadFile.open()
        }
        function onOpenLibBrowser() {
            menuLoader.source = "qrc:/system/System/LibBrowser.qml"
            menuLoader.active = true
        }
        function onSaveAll() {
            saveFile.open()
        }
        function onExit() {
            close()
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
            item.save.connect(()=>{
                mainWindow.closeFlag = true
                saveFile.open()
            })
            item.dicored.connect(()=>{
                mainWindow.closeFlag = false
                msgBox.source = ""
                msgBox.active = false
            })
            item.notSave.connect(()=>{
                mainWindow.closeFlag = true
                mainWindow.close()
            })
            item.closing.connect(()=>{
                msgBox.source = ""
                msgBox.active = false
            })
        }
    }


    property bool closeFlag: false

    onClosing: close => {
        // 此处程序会异步执行,因而有些复杂
        close.accepted = mainWindow.closeFlag
        if (!mainWindow.closeFlag) {
            msgBox.source = "qrc:/mainmenu/MainMenu/MyMessage.qml" 
            msgBox.active = true
        }
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
