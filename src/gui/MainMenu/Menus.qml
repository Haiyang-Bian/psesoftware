import QtQuick 2.3
import QtQuick.Controls

MenuBar {
    signal openProject()

    Menu {
        title: "文件"
        MenuItem {
            text: "新建项目"
            onTriggered: {
                // 在这里添加新建项目的功能
                menuLoader.source = "/mainmenu/MainMenu/ProjectCreate.qml"
                menuLoader.active = true
            }
        }
        MenuItem {
            text: "打开项目"
            onTriggered: {
                // 在这里添加新建项目的功能
                openProject()
            }
        }
        MenuItem {
            text: "打开/关闭库"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "关闭项目"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "关闭所有的项目和方案"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "保存"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "另存为"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "保存所有"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "切换工作区"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "页面设置"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "打印"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "退出"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
    }
    Menu {
        title: "编辑"
        MenuItem {
            text: "前进"
            onTriggered: {
                // 在这里添加新建项目的功能
                menuLoader.source = "/mainmenu/MainMenu/ProjectCreate.qml"
                menuLoader.active = true
            }
        }
        MenuItem {
            text: "回退"
            onTriggered: {
                // 在这里添加新建项目的功能
                
            }
        }
        MenuItem {
            text: "剪切"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "复制"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "粘贴"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "删除"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "前往声明"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "选择所有"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "查找..."
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "前往..."
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "成员"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "用户偏好"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
    }
    Menu {
        title: "视图"
        MenuItem {
            text: "项目树"
            onTriggered: {
                // 在这里添加新建项目的功能
                menuLoader.source = "/mainmenu/MainMenu/ProjectCreate.qml"
                menuLoader.active = true
            }
        }
        MenuItem {
            text: "隐藏库项目"
            onTriggered: {
                // 在这里添加新建项目的功能
                
            }
        }
        MenuItem {
            text: "与编辑器连接"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "文件输入/输出终端"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
    }
    Menu {
        title: "工具"
        MenuItem {
            text: "搜索和替代"
            onTriggered: {
                // 在这里添加新建项目的功能
                menuLoader.source = "/mainmenu/MainMenu/ProjectCreate.qml"
                menuLoader.active = true
            }
        }
        MenuItem {
            text: "比较"
            onTriggered: {
                // 在这里添加新建项目的功能
                
            }
        }
        MenuItem {
            text: "导入多文件"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "与外部文件建立联系"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "导出..."
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
    }
    Menu {
        title: "窗口"
        MenuItem {
            text: "单一编辑器"
            onTriggered: {
                // 在这里添加新建项目的功能
                menuLoader.source = "/mainmenu/MainMenu/ProjectCreate.qml"
                menuLoader.active = true
            }
        }
        MenuItem {
            text: "多编辑器"
            onTriggered: {
                // 在这里添加新建项目的功能
                
            }
        }
        MenuItem {
            text: "级联"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "垂直布局"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "水平布局"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "关闭所有"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
    }
    Menu {
        title: "帮助"
        MenuItem {
            text: "文档"
            onTriggered: {
                // 在这里添加新建项目的功能
                menuLoader.source = "/mainmenu/MainMenu/ProjectCreate.qml"
                menuLoader.active = true
            }
        }
        MenuItem {
            text: "关于"
            onTriggered: {
                // 在这里添加新建项目的功能
                
            }
        }
        MenuItem {
            text: "快捷键"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "函数"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
        MenuItem {
            text: "报告错误"
            onTriggered: {
                // 在这里添加新建项目的功能
                tree.createItem()
            }
        }
    }
}