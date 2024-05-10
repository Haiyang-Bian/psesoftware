#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QJsonDocument>
#include <qsqldatabase.h>
#include <qsqlquery.h>
#include <qsqlerror.h>
#include <qvariant.h>
#include <iterator>
#include "../include/ConnectionType.h"

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

void ConnectionType::insertDB(QVariant dataBase, QString name) {
    QSqlDatabase db = dataBase.value<QSqlDatabase>();
    QSqlQuery query2(db);
    query2.exec(QString(R"(SELECT COUNT(*) FROM "%1"."VariableList")").arg(name));
    int rowCount = 0;
    if (query2.next()) {
        int rowCount = query2.value(0).toInt();
        qDebug() << "表中的总行数是：" << rowCount;
    }
    QSqlQuery query(db);
    query.prepare(QString(R"(INSERT INTO "%1"."ModelList"("Type", "Description") VALUES (?, ?))").arg(name));
    query2.prepare(QString(R"(INSERT INTO "%1"."VariableList"("Id", "Name", "Type", "Model", "Number", "Init", "Value", "Description") VALUES 
        (:id, :name, :type, :model, :num, CAST(:init AS JSONB), :value, :des))").arg(name));
    for (int i : idList) {
        query.addBindValue(typeList.at(i));
        query.addBindValue(descriptionList.at(i));
        if (!query.exec()) {
            qDebug() << "插入错误:" << query.lastError();
        }
        QJsonObject obj = variableList.at(i).getVars();
        for (auto k : obj.keys()) {
            QJsonObject obj1 = obj.value(k).toObject();
            query2.bindValue(":id", rowCount + 1);
            query2.bindValue(":name", k);
            query2.bindValue(":type", obj1.value(QLatin1String("Type")).toString());
            query2.bindValue(":model", typeList.at(i));
            QString unit = obj1.value(QLatin1String("Unit")).toString();
            double value = obj1.value(QLatin1String("Value")).toDouble();
            int num = obj1.value(QLatin1String("Number")).toInt();
            query2.bindValue(":num", num);
            QString min = obj1.value(QLatin1String("Min")).toString();
            QString max = obj1.value(QLatin1String("Max")).toString();
            QString des = obj1.value(QLatin1String("Description")).toString();
            QJsonObject obj2;
            if (unit != "")
                obj2.insert("Unit", unit);
            if (min != "")
                obj2.insert("Min", min);
            if (max != "")
                obj2.insert("Max", max);
            obj2.insert("ConnectType", obj1.value(QLatin1String("ConnectType")));
            QJsonDocument doc(obj2);
            QString jsonString = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));
            query2.bindValue(":init", jsonString);
            QString arr = "{%1}";
            query2.bindValue(":value", arr.arg(value));
            if (des != "")
                query2.bindValue(":des", des);
            else
                query2.bindValue(":des", QVariant(QVariant::String));
            if (!query2.exec()) {
                qDebug() << "插入错误:" << query2.lastError();
            }
            rowCount += 1;
        }
    }
}

void ConnectionType::loadConnsFromDB(QVariant dataBase, QVariantList libs) {
    QSqlDatabase db = dataBase.value<QSqlDatabase>();
    QSqlQuery query1(db), query2(db);
    QString sql1 = R"(SELECT "Type", "Description" FROM "%1"."ModelList" WHERE "Equations" IS NULL AND "Icon" IS NULL;)";
    QString sql2 = R"(SELECT "Name", "Type", "Init" FROM "%1"."VariableList" WHERE "Model" = '%2';)";
    for (auto lib : libs) {
        query1.prepare(sql1.arg(lib.value<QString>()));
        if (!query1.exec()) {
            qDebug() << "查询数据失败：" << query1.lastError().text();
        }
        while (query1.next())
        {
            query2.prepare(sql2.arg(lib.value<QString>()).arg(query1.value(0).toString()));
            if (!query2.exec()) {
                qDebug() << "查询数据失败：" << query2.lastError().text();
            }
            Variable vars;
            while (query2.next())
            {
                QJsonObject obj;
                obj.insert("Name", query2.value(0).toString());
                obj.insert("Type", query2.value(1).toString());
                obj.insert("Connect", QJsonDocument::fromJson(query2.value(2).toByteArray()).object().value(QLatin1String("ConnectType")).toString());
                vars.appendVar(obj);
            }
            query2.clear();
            beginInsertRows(QModelIndex(), this->rowCount(), this->rowCount());
            idList.append(this->rowCount());
            typeList.append(query1.value(0).toString());
            descriptionList.append(query1.value(1).toString());
            variableList.append(vars);
            endInsertRows();
        }
        query1.clear();
    }
    emit updateList();
}