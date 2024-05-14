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
    this->typeList = tmd.typeList;
    this->portList = tmd.portList;
}

ConnectionType& ConnectionType::operator=(const ConnectionType& cao) {
    return const_cast<ConnectionType&>(cao);
}

ConnectionType::~ConnectionType(){
}

int ConnectionType::rowCount(const QModelIndex& parent) const {
    return portList.keys().size();
}

QVariant ConnectionType::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }
    switch (role) {
    case TypeRole:
        return typeList.at(index.row());
    case DescriptionRole:
        return portList.value(typeList.at(index.row())).des;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ConnectionType::roleNames() const {
    static QHash<int, QByteArray> roles{
        {TypeRole, "Type"},
        {DescriptionRole,"Description"}
    };
    return roles;
}

// 以对象组的形式返回端口列表
QJsonArray ConnectionType::getTypes() {
    QJsonArray types;
    for (QString type : typeList) {
        QJsonObject conn = portList.value(type).getPort();
        conn.insert("Type", type);
        types.append(conn);
    }
    return types;
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
                    QString name = port.value("Type").toString();
                    typeList.append(name);
                    portList.insert(name, Port(port));
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
            QString name = port.value("Type").toString();
            typeList.append(name);
            portList.insert(name, Port(port));
        }
        endInsertRows();
    }
}
