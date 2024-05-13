#include "../include/VariableType.h"
#include <QDebug>
#include <qurl.h>
#include <QFile>
#include <QJsonDocument>
#include <iostream>
#include <QNetworkRequest>
#include <QNetworkReply>

QList<QJsonObject> VariableType::standarType;

VariableType::VariableType(const VariableType& tmd) {
    this->varTypes = tmd.varTypes;
}

QVariant VariableType::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }
    QJsonObject obj = varTypes.at(index.row());
    qDebug() << obj;
    switch (role) {
    case IdRole:
        return m_idList.at(index.row());
    case NameRole:
        return obj["Name"].toVariant();
    case UnitRole:
        return obj["Unit"].toVariant();
    case DefaultValueRole:
        return obj["DefaultValue"].toVariant();
    case MinRole:
        return obj["Min"].toVariant();
    case MaxRole:
        return obj["Max"].toVariant();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> VariableType::roleNames() const {
    static QHash<int, QByteArray> roles{
        {IdRole,"id"},
        {NameRole,"name"},
        {UnitRole,"unit"},
        {DefaultValueRole,"defaultValue" },
        {MinRole,"min"},
        {MaxRole,"max" }
    };
    return roles;
}

//注入初始数据
void VariableType::setVariable(const QJsonArray VariableJsonArray) {
    beginResetModel();  //重置数据必须遵循的规则，表示开始
    
    endResetModel(); //重置数据必须遵循的规则，表示结束
}

void VariableType::saveTypes(QUrl path) {
    QFile file(path.toLocalFile());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qWarning() << "Could not open file!";
        return;
    }
    QTextStream out(&file);
    for (QJsonObject type : varTypes) {
        out << QJsonDocument(type).toJson().constData();
    }
    out.flush();
    file.close();
}

void VariableType::loadTypes(QUrl path) {
    QFile file(path.toLocalFile());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qWarning() << "Could not open file!";
        return;
    }
    QString val = file.readAll();
    file.close();
    QJsonArray doc = QJsonDocument::fromJson(val.toUtf8()).array();
    //插入数据需遵循的规则，表示开始
    int index = this->rowCount();
    beginInsertRows(QModelIndex(), index, index + doc.size() - 1); //第一个参数表示在顶级根(由于是列表结构所以表示当前列表的根）,第二个参数表示起始位置，第三个参数表示结束位置，由于只有一列，所以两者都一样
    for (int i = 0; i < doc.size(); ++i) {
        // 使用insert不会覆盖,为什么用append就会覆盖之前的值呢?C++黑魔法?
        varTypes.append(doc.at(i).toObject());
    }
    endInsertRows();    //插入数据需遵循的规则，表示结束
}

QString VariableType::getType(int index, int role) {
    if (index < 0 || index > this->rowCount()) {
        return QString();
    }
    QJsonObject type = varTypes.at(index);
    switch (role) {
    case 0:
        return type.value("Name").toString();
    case 1:
        return type.value("Unit").toString();
    case 2:
        return QString("%1").arg(type.value("DefaultValue").toDouble());
    case 3:
        return type.value("Min").toString();
    case 4:
        return type.value("Max").toString();
    default:
        return QString();
    }
}

int VariableType::getIdByType(QString type) {
    QList<QJsonObject>::iterator it = varTypes.begin();
    QList<QJsonObject>::iterator rit = varTypes.end() - 1;
    while (it < rit)
    {
        if (it->value("Name") == type)
            return it - varTypes.begin();
        if (rit->value("Name") == type)
            return rit - varTypes.begin();
        it++;
        rit--;
    }
    return -1;
}


QJsonArray VariableType::saveTypes() {
    QJsonArray ans;
    for (QJsonObject type : varTypes) {
        ans.append(type);
    }
    return ans;
}

void VariableType::loadTypesFromDataBase() {
    if (standarType.isEmpty()){
        QNetworkRequest request(QUrl("http://localhost:8080/physicalDatas"));
        QNetworkReply* reply = manager.get(request);
        connect(&manager, &QNetworkAccessManager::finished, this, [this, reply](){
            if (reply->error()) {
                qDebug() << "Error:" << reply->errorString();
                return;
            }
            QJsonObject res = QJsonDocument::fromJson(reply->readAll()).object();
            QJsonArray arr = res.value("Types").toArray();
            beginInsertRows(QModelIndex(), 0, arr.size() - 1);
            for (auto v : arr) {
                QJsonObject query = v.toObject();
                varTypes.append(query);
                standarType.append(query);
            }
            endInsertRows();
            reply->deleteLater();
        });
    }
    else {
        beginInsertRows(QModelIndex(), this->rowCount(), this->rowCount() + standarType.size() - 1);
        for (QJsonObject d : standarType) {
            varTypes.append(d);
        }
        endInsertRows();
    }
}