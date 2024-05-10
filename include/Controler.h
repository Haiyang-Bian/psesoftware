#pragma once

#include <QObject>
#include <qnetworkaccessmanager.h>
#include <qsqldatabase.h>
#include <qmetatype.h>
#include "Model.h"
#include "ConnectionType.h"
#include "VariableType.h"
#include "DndControler.h"
#include <qqmlengine.h>

// 项目类
class Project
{
public:
	Project(){}
	~Project() {}

	// 变量类型表
	VariableType varTypes;
	// 连接类型表
	ConnectionType connTypes;
	// 模型列表
	ModelList models;
	// 流程(系统)列表
	QMap<QString, DndControler> system;
};


// 可拖放组件列表
struct DndComp
{
	QString type;
	QByteArray icon;
	QJsonArray handlers;
	QJsonArray paras;
	QString des;
};


// 软件整体控制类,MVC架构
class Controler  : public QObject
{
	Q_OBJECT

public:
	Controler(QObject* parent = nullptr) : QObject(parent) {}
	~Controler(){}

	// 加解密函数
	QString enCoder(QByteArray text);
	void deCoder(QString text);

	// 数据库
	void connectDataBase();
	QJsonArray getDataTypes();

	// 保存某一工程(JSON格式)
	void saveOneProject(QString path, QString pname);
	// XML格式
	void saveOneProjectXML(QString path, QString pname);

	// qml访问成员使用的函数
	Q_INVOKABLE inline VariableType* getVarTypes(QString name) {
		return &(projects[name].varTypes);
	}
	Q_INVOKABLE inline ConnectionType* getConnTypes(QString name) {
		return &(projects[name].connTypes);
	}
	Q_INVOKABLE inline ModelList* getModels(QString name) {
		return &(projects[name].models);
	}
	Q_INVOKABLE inline DndControler* getDnd(QString name, QString process) {
		return &(projects[name].system[process]);
	}

	// 项目管理
	Q_INVOKABLE void creatProject(QString name);
	Q_INVOKABLE void saveProject(QUrl path);
	Q_INVOKABLE void loadProject(QUrl path);

	// 流程(系统)管理
	Q_INVOKABLE QList<QString> getSystems(QString name);
	Q_INVOKABLE void createSystem(QString name, QString sname);
	Q_INVOKABLE void removeSystem(QString name, QString sname);

	// 组件库管理
	Q_INVOKABLE QJsonArray loadLibs();
	Q_INVOKABLE void selectLibs(QVariantList libs);

	// 数据库交互
	Q_INVOKABLE QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
	Q_INVOKABLE void linkLibrary();

	// 生成仿真文件
	Q_INVOKABLE void generateSimulation(QString name, QString process);
	// 返回系统信息
	Q_INVOKABLE inline QJsonObject systemInfo(QString name, QString process) {
		return projects[name].system[process].sysInfo;
	}
	// 仿真计算
	Q_INVOKABLE void simulation(QJsonObject settings);

signals:
	// 仿真结束后告诉UI进行绘图
	void simulationEnd(QJsonObject ans);

private:
	// 项目列表
	QMap<QString, Project> projects;
	// 使用的库列表
	QList<QString> libList;
	// 库里的组件列表
	QMap<QString, QList<DndComp>> compList;
	// HTTP
	QNetworkAccessManager* netWorker;
};
