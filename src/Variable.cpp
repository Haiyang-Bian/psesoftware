#include "../include/Variable.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QJsonDocument>

Variable::Variable(QObject* parent) : QAbstractListModel(parent)
{
    this->isParameter = false;
    this->idList = QList<int>();
    this->metaDataList = QList<MetaData>();
}

// 该拷贝构造函数与其后的操作符一同使用,为动态类数组所必须
Variable::Variable(const Variable& tmd) {
    QObject* parent = nullptr;
    this->isParameter = tmd.isParameter;
    this->idList = tmd.idList;
    this->metaDataList = tmd.metaDataList;
}

int Variable::rowCount(const QModelIndex& parent) const {
    return idList.size();
}

QVariant Variable::data(const QModelIndex& index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }
    switch (role) {
    case IdRole:
        return idList.at(index.row());
    case NameRole:
        return metaDataList.at(index.row()).name;
    case TypeRole:
        return metaDataList.at(index.row()).type;
    case UnitRole:
        return metaDataList.at(index.row()).unit;
    case ValueRole:
        return QVariant(metaDataList.at(index.row()).value);
    case MinRole:
        return get<0>(metaDataList.at(index.row()).bound);
    case MaxRole:
        return get<1>(metaDataList.at(index.row()).bound);
    case DescriptionRole:
        return metaDataList.at(index.row()).description;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> Variable::roleNames() const {
    static QHash<int, QByteArray> roles{
        {IdRole,"id"},
        {NameRole,"name"},
        {UnitRole,"unit"},
        {ValueRole,"value" },
        {MinRole,"min"},
        {MaxRole,"max" },
        {DescriptionRole,"description"}
    };
    return roles;
}

//注入初始数据
void Variable::setVariable(const QJsonArray DataArray) {
    //重置数据必须遵循的规则，表示开始
    beginResetModel();  
    metaDataList.clear();
    idList.clear();
    for (int i = 0; i < DataArray.size(); i++) {
        QJsonObject obj = DataArray.at(i).toObject();
        MetaData metaData(
            obj["name"].toString(),
            obj["type"].toString(),
            obj["unit"].toString(),
            obj["value"].toDouble(),
            tuple<QString, QString>(
                obj["min"].toString(),
                obj["max"].toString()
            ),
            obj["connect"].toString(),
            obj["description"].toString()
        );
        metaDataList << metaData;
        idList << i;
    }
    endResetModel(); //重置数据必须遵循的规则，表示结束
}

//增加数据
void Variable::insertVariable(QJsonObject DataObject, int index) {
    if (index <0 || index > rowCount()) //无效处理
        return;
    MetaData metaData;
    metaData.name = DataObject.value(QLatin1String("name")).toString();
    metaData.type = DataObject.value(QLatin1String("type")).toString();
    metaData.unit = DataObject.value(QLatin1String("unit")).toString();
    metaData.value = DataObject.value(QLatin1String("value")).toDouble();
    QString min = DataObject.value(QLatin1String("min")).toString();
    QString max = DataObject.value(QLatin1String("max")).toString();
    metaData.bound = tuple<QString, QString>(min, max);
    metaData.connect = DataObject.value(QLatin1String("connect")).toString();
    metaData.description = DataObject.value(QLatin1String("description")).toString();
    idList.insert(index, 1);
    //插入数据需遵循的规则，表示开始
    beginInsertRows(QModelIndex(), index, index); //第一个参数表示在顶级根(由于是列表结构所以表示当前列表的根）,第二个参数表示起始位置，第三个参数表示结束位置，由于只有一列，所以两者都一样
    metaDataList.insert(index, metaData);
    endInsertRows();    //插入数据需遵循的规则，表示结束
}

//移除数据
void Variable::removeVariable(int index) {
    if (index < 0 || index > rowCount())return;
    idList.removeAt(index);
    beginRemoveRows(QModelIndex(), index, index); //移除数据需遵循的规则，表示开始
    metaDataList.removeAt(index);
    endRemoveRows();	//移除数据需遵循的规则，表示结束
}

// 修改index处的变量
void Variable::editVariable(QJsonObject Obj, int index) const
{
    QString name = "";
    if (Obj.contains(QLatin1String("Name")))
        name = Obj.value(QLatin1String("Name")).toString();
    QString type = "";
    if (Obj.contains(QLatin1String("Type")))
        type = Obj.value(QLatin1String("Type")).toString();
    QString unit = "";
    if (Obj.contains(QLatin1String("Unit")))
        unit = Obj.value(QLatin1String("Unit")).toString();
    QString value = "";
    if (Obj.contains(QLatin1String("DefaultValue")))
        value = Obj.value(QLatin1String("DefaultValue")).toString();
    QString min = "";
    if (Obj.contains(QLatin1String("Min")))
        min = Obj.value(QLatin1String("Min")).toString();
    QString max = "";
    if (Obj.contains(QLatin1String("Max")))
        max = Obj.value(QLatin1String("Max")).toString();
    QString con = "";
    if (Obj.contains(QLatin1String("Connect")))
        con = Obj.value(QLatin1String("Connect")).toString();

    if (name != "") 
        metaDataList[index].name = name;
    if (type != "")
        metaDataList[index].type = type;
    if (unit != "") 
        metaDataList[index].unit = unit;
    if (value != "")
        metaDataList[index].value = value.toDouble();
    if (min != "")
        get<0>(metaDataList[index].bound) = min;
    if (max != "")
        get<1>(metaDataList[index].bound) = max;
    con != "" ? metaDataList[index].connect = con : [] { return QString(""); }();
}

QString Variable::getVariable(int index, int role) {
    if (index < 0 || index > this->rowCount()) {
        return QString();
    }
    switch (role) {
    case 1:
        return QString::number((int)idList.at(index));
    case 2:
        return metaDataList.at(index).name;
    case 3:
        return metaDataList.at(index).type;
    case 4:
        return metaDataList.at(index).unit;
    case 5:
        return QString::number((double)metaDataList.at(index).value);
    case 6:
        return get<0>(metaDataList.at(index).bound);
    case 7:
        return get<1>(metaDataList.at(index).bound);
    case 8:
        return metaDataList.at(index).connect;
    default:
        return QString();
    }
}

void Variable::appendVar(const QJsonObject Obj) {
    if (rowCount() > 0)
        idList.append(*(idList.end()) + 1);
    else
        idList.append(0);
    metaDataList << Obj;
}

QJsonObject Variable::getVars() const{
    QJsonObject vars;
    for (int i = 0; i < metaDataList.size(); i++) {
        QJsonObject data;
        data.insert("Unit", metaDataList[i].unit);
        data.insert("Type", metaDataList[i].type);
        data.insert("Min", get<0>(metaDataList[i].bound));
        data.insert("Max", get<1>(metaDataList[i].bound));
        data.insert("Description", metaDataList[i].description);
        data.insert("ConnectType", metaDataList[i].connect);
        data.insert("Value", metaDataList[i].value);
        data.insert("Number", metaDataList[i].number);
        if (metaDataList[i].guiMetaData != "")
            data.insert("Gui", metaDataList[i].guiMetaData);
        vars.insert(metaDataList[i].name, data);
    }
    return vars;
}
