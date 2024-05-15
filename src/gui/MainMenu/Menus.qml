import QtQuick 2.3
import QtQuick.Controls

MenuBar {
    signal creatProject()
    signal openProject()
    signal openLibBrowser()
    signal saveAll()
    signal exit()

    Menu {
        title: "文件"
        MenuItem {
            text: "新建项目"
            onTriggered: {
                creatProject()
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
                openLibBrowser()
            }
        }
        MenuItem {
            text: "关闭项目"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "关闭所有的项目和方案"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "保存"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "另存为"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "保存所有"
            onTriggered: {
                saveAll()
            }
        }
        MenuItem {
            text: "切换工作区"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "页面设置"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "打印"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "退出"
            onTriggered: {
                exit()
            }
        }
    }
    Menu {
        title: "编辑"
        MenuItem {
            text: "前进"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "回退"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "剪切"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "复制"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "粘贴"
            onTriggered: {
               
            }
        }
        MenuItem {
            text: "删除"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "前往声明"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "选择所有"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "查找..."
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "前往..."
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "成员"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "用户偏好"
            onTriggered: {
                
            }
        }
    }
    Menu {
        title: "视图"
        MenuItem {
            text: "项目树"
            onTriggered: {
               
            }
        }
        MenuItem {
            text: "隐藏库项目"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "与编辑器连接"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "文件输入/输出终端"
            onTriggered: {
                
            }
        }
    }
    Menu {
        title: "工具"
        MenuItem {
            text: "搜索和替代"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "比较"
            onTriggered: {
                
                
            }
        }
        MenuItem {
            text: "导入多文件"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "与外部文件建立联系"
            onTriggered: {
            }
        }
        MenuItem {
            text: "导出..."
            onTriggered: {
                
            }
        }
    }
    Menu {
        title: "窗口"
        MenuItem {
            text: "单一编辑器"
            onTriggered: {
                
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
                
            }
        }
        MenuItem {
            text: "垂直布局"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "水平布局"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "关闭所有"
            onTriggered: {
                
            }
        }
    }
    Menu {
        title: "帮助"
        MenuItem {
            text: "文档"
            onTriggered: {
                
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
                
            }
        }
        MenuItem {
            text: "函数"
            onTriggered: {
                
            }
        }
        MenuItem {
            text: "报告错误"
            onTriggered: {
                
            }
        }
    }
}