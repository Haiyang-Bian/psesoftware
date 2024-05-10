#include <QApplication>
#include <QQmlApplicationEngine>
#include <QJsonArray>
#include <QJsonObject>
#include <qicon.h>
#include <qjsondocument.h>
#include <qqmlcontext.h>
#include "../include/VariableType.h"
#include "../include/ConnectionType.h"
#include "../include/Model.h"
#include "../include/TreeModel.h"
#include "../include/DndTree.h"
#include "../include/Controler.h"
#include "../include/DndControler.h"
#include <iostream>
#include <jluna.hpp>

using namespace jluna;

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    jluna::initialize(4, false);
    QApplication app(argc, argv);
    //app.setWindowIcon(QIcon("./logo.png"));
    //Main.safe_eval_file("D:/Work/leetcode/QtModelBuilder/JuliaCore/Environment.jl");
    //Main.safe_eval(R"(cd("./WorkPath"))");
    
    QQmlApplicationEngine engine;

    Controler controler;
    controler.creatProject("Project_1");
    engine.rootContext()->setContextProperty("Controler", &controler);
    controler.connectDataBase();

    qmlRegisterType<MyTreeModel>("Ai4Energy", 1, 0, "TreeModel");
    qmlRegisterType<VariableType>("Ai4Energy", 1, 0, "VarModel");
    qmlRegisterType<ConnectionType>("Ai4Energy", 1, 0, "ConnModel");
    qmlRegisterType<ModelList>("Ai4Energy", 1, 0, "ModelList");
    qmlRegisterType<DndControler>("Ai4Energy", 1, 0, "DndControler");
    qmlRegisterType<DndTree>("Ai4Energy", 1, 0, "DndTreeModel");

    engine.load(QUrl(QStringLiteral("qrc:/mainWindow/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}