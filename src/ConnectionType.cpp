#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QJsonDocument>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <qvariant.h>
#include <iterator>
#include "../include/ConnectionType.h"

QJsonArray ConnectionType::standardTypes;

ConnectionType::ConnectionType(QObject* parent) : QAbstractListModel(parent) {}

ConnectionType::ConnectionType(const ConnectionType& tmd) {
    this->idList = tmd.idList;
    this->typeList = tmd.typeList;
    this->variableList = tmd.variableList;
    this->descriptionList = tmd.descriptionList;
}

ConnectionType& ConnectionType::operator=(const ConnectionType& cao) {
    return const_cast<ConnectionType&>(cao);
}

ConnectionType::~ConnectionType(){
}

int ConnectionType::rowCount(const QModelIndex& parent) const {
    return idList.size();
}

QVariant ConnectionType::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }
    switch (role) {
    case IdRole:
        return idList.at(index.row());
    case TypeRole:
        return typeList.at(index.row());
    case DescriptionRole:
        return descriptionList.at(index.row());
    default:
        return QVariant();
    }
}

QList<QString> ConnectionType::getTypeList() {
    return typeList;
}

QHash<int, QByteArray> ConnectionType::roleNames() const {
    static QHash<int, QByteArray> roles{
        {IdRole,"id"},
        {TypeRole, "type"},
        {DescriptionRole,"description"}
    };
    return roles;
}

//注入初始数据
void ConnectionType::setConnectionType() {
    beginResetModel();  //重置数据必须遵循的规则，表示开始
    idList.clear();
    typeList.clear();
    variableList.clear();
    descriptionList.clear();
    idList.append(0);
    MetaData metaData;
    Variable var;
    var.idList.append(0);
    (var.metaDataList).append(metaData);
    variableList.append(var);
    typeList.append(QString("Nothing"));
    descriptionList.append(QString("Nothing"));
    endResetModel(); //重置数据必须遵循的规则，表示结束
}

// 表尾增加数据
void ConnectionType::appendType(const QJsonObject& DataObject) 
{
    // 先更新id,
    idList.append(this->rowCount());
    QString type = QString("");
    if (DataObject.contains("Type"))
        type = DataObject.value(QLatin1String("Type")).toString();
    else {
        throw("Error:0001");
        return;
    }
    variableList << Variable();
    QString des = QString("");
    if (DataObject.contains("Description"))
        des = DataObject.value(QLatin1String("Description")).toString();
    // rowCount由idList长度决定,因而先更新idList会使插入处为空,故而减一
    beginInsertRows(QModelIndex(), this->rowCount() - 1, this->rowCount() - 1);
    typeList.append(type);
    descriptionList.append(des);
    endInsertRows(); 
    // 插入数据需遵循的规则，表示结束
}

//移除数据
void ConnectionType::removeType(int index) {
    if (index < 0 || index > rowCount())return;
    beginRemoveRows(QModelIndex(), index, index); 
    idList.removeAt(index);
    typeList.removeAt(index);
    variableList.removeAt(index);
    descriptionList.removeAt(index);
    endRemoveRows();	
}

void ConnectionType::editType(const QJsonObject Obj, int c_index, int index) {
    // 此处的index指要编辑的端口变量的index
    // c_index为端口类型的序号
    // UI若无大问题,此函数应当在编辑窗口处使用
    if (c_index < 0 || c_index > rowCount())return;
    int v_count = variableList.at(c_index).rowCount();
    if (index < 0 || index > v_count)return;
    (variableList[c_index]).editVariable(Obj, index);
}

// 以对象组的形式返回端口列表
QJsonArray ConnectionType::getTypes() {
    QJsonArray types;
    for (int i : idList) {
        QJsonObject con;
        QJsonObject vars = variableList.at(i).getVars();
        QJsonArray nVars;
        for (QString j : vars.keys()) {
            QJsonObject var = vars.value(QLatin1String(j.toStdString())).toObject();
            var.insert("Name", j);
            nVars.append(var);
        }
        con.insert("Type", typeList.at(i));
        con.insert("Description", descriptionList.at(i));
        con.insert("Variables", nVars);
        types.append(con);
    }
    return types;
}

void ConnectionType::createConnectionVar(const QJsonObject& Var, int index)
{   
    // index为要新建变量的端口的序号(id)
    variableList[index].appendVar(Var);
}

void ConnectionType::removeConnectionVar(int c_index, int index) {
    variableList[c_index].removeVariable(index);
}

QString ConnectionType::getVarType(int c_index, int index, int role) {
    return variableList[c_index].getVariable(index, role);
}

void ConnectionType::insertDB() {
    QNetworkRequest request(QUrl("http://localhost:8080/portTypes"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject jsonPayload;
    jsonPayload.insert("PortTypes", this->getTypes());
    QByteArray jsonData = QJsonDocument(jsonPayload).toJson();
    manager.post(request, jsonData);
    connect(&manager, &QNetworkAccessManager::finished, this, [](QNetworkReply* reply){
        if (reply->error()) {
            qDebug() << "请求失败:" << reply->errorString();
        }
        else {
            // 读取响应的内容
            QByteArray responseData = reply->readAll();
            qDebug() << "响应内容:" << responseData;
        }
        reply->deleteLater();
    });
}

void ConnectionType::loadConnsFromDB() {
    if (standardTypes.isEmpty()) {
        QNetworkRequest request(QUrl("http://localhost:8080/portTypes"));
        manager.get(request);
        connect(&manager, &QNetworkAccessManager::finished, this, [this](QNetworkReply* reply) {
            if (reply->error()) {
                qDebug() << "请求失败:" << reply->errorString();
            }
            else {
                // 读取响应的内容
                QJsonObject res = QJsonDocument::fromJson(reply->readAll()).object();
                QJsonArray arr = res["PortTypes"].toArray();
                standardTypes = arr;
                beginInsertRows(QModelIndex(), 0, arr.size() - 1);
                for (auto type : arr) {
                    QJsonObject port = type.toObject();
                    Variable vars;
                    for (auto var : port.value("Variables").toArray())
                        vars.appendVar(var.toObject());
                    idList.append(this->rowCount());
                    typeList.append(port.value("Type").toString());
                    descriptionList.append(port.value("Description").toString());
                    variableList.append(vars);
                }
                endInsertRows();
                emit updateList();
            }
            reply->deleteLater();
            });
    }
    else
    {
        beginInsertRows(QModelIndex(), 0, standardTypes.size() - 1);
        for (auto type : standardTypes) {
            QJsonObject port = type.toObject();
            Variable vars;
            for (auto var : port.value("Variables").toArray())
                vars.appendVar(var.toObject());
            idList.append(this->rowCount());
            typeList.append(port.value("Type").toString());
            descriptionList.append(port.value("Description").toString());
            variableList.append(vars);
        }
        endInsertRows();
    }
}