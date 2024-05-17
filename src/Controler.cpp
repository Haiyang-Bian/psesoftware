#include "../include/Controler.h"
#include <qurl.h>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <qurlquery.h>
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

    out << doc;
    file.close();
}

void Controler::creatProject(QString name) {
    projects.insert(name, Project());
    QQmlEngine::setObjectOwnership(&(projects[name].connTypes), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(&(projects[name].models), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(&(projects[name].varTypes), QQmlEngine::CppOwnership);
}

QJsonArray Controler::getSystems(QString name) {
    QJsonArray sys;
    for (const QString s : projects.value(name).system.keys()) {
        sys << s;
    }
    return sys;
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
    compList.loadLibs(libList);
}

void Controler::generateSimulation(QString name, QString process) {
    QUrl url("http://localhost:8080/simulation");
    QUrlQuery query;
    query.addQueryItem("type", "analysis_system");
    url.setQuery(query);
    QNetworkRequest request(url);
    QJsonObject json = projects.value(name).system.value(process).systemData();
    QNetworkReply* reply = netWorker.post(request, QJsonDocument(json).toJson().constData());
    connect(&netWorker, &QNetworkAccessManager::finished, this, [this](QNetworkReply* r) {
        QJsonObject res = QJsonDocument::fromJson(r->readAll()).object();
        emit this->analysisEnd(res);
        });
}

void Controler::simulation(QJsonObject settings)
{
    QUrl url("http://localhost:8080/simulation");
    QUrlQuery query;
    query.addQueryItem("type", "calculation");
    url.setQuery(query);
    QNetworkRequest request(url);
    QNetworkReply* reply = netWorker.post(request, QJsonDocument(settings).toJson().constData());
    connect(&netWorker, &QNetworkAccessManager::finished, this, [this](QNetworkReply* r) {
        QJsonObject res = QJsonDocument::fromJson(r->readAll()).object();
        emit simulationEnd(res);
        });
}
