#include "../include/Controler.h"
#include <qurl.h>
#include <qfile.h>
#include <qjsondocument.h>
#include <iostream>
#include <QDir>

void Controler::saveProject(QUrl path) 
{
    QDir project(path.toLocalFile());
    for (QString pname : projects.keys()) {
        this->saveOneProject(project.path(), pname);
    }
}

void Controler::saveOneProjectXML(QString path, QString pname)
{

}

void Controler::loadProject(QUrl path) {
    QFile project(path.toLocalFile());
    QString name = ((path.toString().split('/').end() - 1)->split('.'))[0];
    Project np;
    if (!project.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << project.fileName();
        qWarning() << "Could not open file!";
        return;
    }
    QTextStream in(&project);
    QJsonObject p = QJsonDocument::fromJson(in.readAll().toUtf8()).object();
    np.varTypes.setVariable(p.value("DataTypes").toArray());
    np.connTypes.loadTypes(p.value("ConnectionTypes").toArray());
    np.models.loadModels(p.value("ModelList").toArray());
    projects.insert(name, np);
}

void Controler::connectDataBase() {
   
}

QJsonArray Controler::getDataTypes() {
    return QJsonArray();
}

void Controler::saveOneProject(QString path, QString pname)
{
    QFile file(path + "/"+ pname + ".aife");
    QJsonObject project;
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qDebug() << file.fileName();
        qWarning() << "Could not open file!";
        return;
    }
    QTextStream out(&file);
    QJsonArray vars = projects[pname].varTypes.saveTypes();
    project.insert("DataTypes", vars);

    QJsonArray cons = projects[pname].connTypes.getTypes();
    project.insert("ConnectionTypes", cons);
    
    QJsonArray models = projects[pname].models.saveModels();
    project.insert("ModelList", models);

    QJsonObject systems;
    QMap<QString, DndControler>::const_iterator it;
    const QMap<QString, DndControler>& s = projects[pname].system;
    for (it = s.begin(); it != s.end(); ++it) {
        systems.insert(it.key(), it->systemData());
    }
    project.insert("Systems", systems);

    QByteArray doc = QJsonDocument(project).toJson();
    file.close();
}

void Controler::creatProject(QString name) {
    projects.insert(name, Project());
    QQmlEngine::setObjectOwnership(&(projects[name].connTypes), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(&(projects[name].models), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(&(projects[name].varTypes), QQmlEngine::CppOwnership);
}

QList<QString> Controler::getSystems(QString name) {
    return projects.value(name).system.keys();
}

void Controler::createSystem(QString name, QString sname){
    projects[name].system.insert(sname, DndControler());
    QQmlEngine::setObjectOwnership(&(projects[name].system[sname]), QQmlEngine::CppOwnership);
}
void Controler::removeSystem(QString name, QString sname){
    projects[name].system.remove(sname);
}

void Controler::selectLibs(QVariantList libs) {
    libList.clear();
    for (QVariant v : libs) {
        libList.append(v.toString());
    }
    this->linkLibrary();
}

void Controler::linkLibrary() {
    
}

void Controler::generateSimulation(QString name, QString process) {
    QFile file("D:/Work/leetcode/QtModelBuilder/WorkPath/tempfile.aife");
    QJsonObject system;
    system.insert("Packages", [this]() -> QJsonArray {
        QJsonArray ps;
        for (QString p : this->libList)
            ps.append(p);
        return ps;
        }());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning("无法打开文件进行写入");
    }
    // 创建一个QTextStream对象，用于写入文本到文件
    QTextStream out(&file);

    // 使用QTextStream写入文本
    out << QJsonDocument(system).toJson(QJsonDocument::Indented);
    // 关闭文件
    file.close();
}

void Controler::simulation(QJsonObject settings)
{
    QJsonDocument doc(settings);
    QString jsonString = doc.toJson(QJsonDocument::Compact);
}

QJsonArray Controler::loadLibs() {
    QJsonArray libs;
    for (QString k : compList.keys()) {
        QJsonObject lib;
        lib.insert("Name", k);
        QJsonArray models;
        for (DndComp c : compList[k]) {
            QJsonObject model;
            model.insert("Type", c.type);
            model.insert("Icon", QString("data:image/png;base64,%1").arg(c.icon.constData()));
            model.insert("Handlers", c.handlers);
            model.insert("Paras", c.paras);
            model.insert("Des", c.des);
            models.append(model);
        }
        lib.insert("Models", models);
        libs.append(lib);
    }
    return libs;
}