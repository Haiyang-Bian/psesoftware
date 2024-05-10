#include "../include/Model.h"
#include <qimage.h>
#include <qimagereader.h>
#include <qbuffer.h>
#include <qsqldatabase.h>
#include <qsqlquery.h>
#include <qsqlerror.h>
#include <iostream>
#include <qjsondocument.h>

ModelList::ModelList(QObject* parent) : QAbstractItemModel(parent)
{
    rootItem = new Model;
}

QModelIndex ModelList::index(int row, int column, const QModelIndex& parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();
    Model* parentItem = getItem(parent);
    auto childPtr = parentItem->subItems.at(row);
    if (childPtr) {
        return createIndex(row, column, childPtr);
    }
    else {
        return QModelIndex();
    }
}

QModelIndex ModelList::parent(const QModelIndex& index) const
{
    if (!index.isValid()) {
        return QModelIndex();
    }
    Model* childItem = getItem(index);
    auto parentPtr = childItem->parentItem;
    if (!parentPtr || parentPtr == rootItem) {
        return QModelIndex();
    }
    return createIndex(parentPtr->row, 0, parentPtr);
}

int ModelList::rowCount(const QModelIndex& parent) const
{
    Model* parentItem = getItem(parent);
    return parentItem->subItems.size();
}

int ModelList::columnCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
        return 1;
}

QVariant ModelList::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    Model* item = getItem(index);
    if (role == Qt::DisplayRole) {
        //TreeView继承自TableView，所以可以通过不同的column来取单元格数据
        role = Qt::UserRole + index.column();
    }
    switch (role) {
    case NameRole: return item->name;
    case TypeRole: return item->isFilter ? "Filter" : "Normal";
    default: break;
    }
    return QVariant();
}

QHash<int, QByteArray> ModelList::roleNames() const
{
    QHash<int, QByteArray> names = QAbstractItemModel::roleNames();
    names.insert(QHash<int, QByteArray>{
        {NameRole, "name"},
        { TypeRole, "type" }
    });
    return names;
}

void ModelList::resetItems()
{
    if (rootItem->subItems.isEmpty()) {
        beginResetModel();
        Model* lv1{ new Model }, * l2{ new Model };
        lv1->parentItem = rootItem;
        rootItem->subItems.append(lv1);
        lv1->row = 0;
        lv1->name = "NewLib1";
        endResetModel();
    }
}

Model* ModelList::getItem(const QModelIndex& idx) const
{
    if (idx.isValid()) {
        Model* item = static_cast<Model*>(idx.internalPointer());
        if (item) {
            return item;
        }
    }
    return rootItem;
}

void ModelList::createItem(QModelIndex order, bool isFilter, QString name) {
    Model* lv1{ new Model };
    Model* father = getItem(order);
    beginInsertRows(order, this->rowCount(order), this->rowCount(order));
    lv1->parentItem = father;
    lv1->row = this->rowCount(order);
    father->subItems << lv1;
    lv1->isFilter = isFilter;
    lv1->name = name;
    endInsertRows();
}

void ModelList::removeItem(QModelIndex order) {
    // 很遗憾这里不能使用QSharedPointer,否则会触发访问权限冲突的问题
    // 我并没有找到解决方法
    beginRemoveRows(this->parent(order), order.row(), order.row());
    Model* father = getItem(parent(order));
    father->subItems[order.row()]->parentItem = nullptr;
    bool isFilter = father->subItems[order.row()]->isFilter;
    QList<Model*> subItems = father->subItems[order.row()]->subItems;
    for (auto item : subItems) {
        item->parentItem = father;
    }
    delete father->subItems[order.row()];
    father->subItems.remove(order.row());
    endRemoveRows();
    if (isFilter && !subItems.isEmpty()) {
        beginInsertRows(createIndex(father->row, 0, father), father->subItems.size(), father->subItems.size() + subItems.size() - 1);
        for (auto item : subItems) {
            father->subItems.append(item);
        }
        endInsertRows();
    }
    for (int i = order.row(); i < father->subItems.size(); ++i) {
        father->subItems[i]->row = i;
    }
}

void ModelList::moveItem(QModelIndex order, QModelIndex target) {
    Model* s = getItem(order);
    Model* t = getItem(target);
    if (t->isFilter) {
        // 同级目录等同于不拖
        if (parent(order) == target)
            return;
        beginMoveRows(parent(order), s->row, s->row, target, t->subItems.size());
        s->parentItem->subItems[s->row] = nullptr;
        s->parentItem->subItems.removeAt(s->row);
        for (int i = s->row; i < s->parentItem->subItems.size(); ++i) {
            s->parentItem->subItems[i]->row = i;
        }
        s->parentItem = t;
        s->row = t->subItems.size();
        t->subItems << s;
        endMoveRows();
    }
    else
    {
        if (parent(order) == parent(target))
            return;
        beginMoveRows(parent(order), s->row, s->row, parent(target), t->row);
        s->parentItem->subItems[s->row] = nullptr;
        s->parentItem->subItems.removeAt(s->row);
        for (int i = s->row; i < s->parentItem->subItems.size(); ++i) {
            s->parentItem->subItems[i]->row = i;
        }
        s->parentItem = t->parentItem;
        t->parentItem->subItems.insert(t->row, s);
        for (int i = t->row; i < t->parentItem->subItems.size(); ++i) {
            t->parentItem->subItems[i]->row = i;
        }
        endMoveRows();
    }
}

void ModelList::createLib(QString name) {
    beginInsertRows(QModelIndex(), rootItem->subItems.size(), rootItem->subItems.size());
    Model* newLib{ new Model };
    newLib->parentItem = rootItem;
    newLib->row = rootItem->subItems.size();
    newLib->name = name;
    rootItem->subItems << newLib;
    endInsertRows();
}

void ModelList::changeName(QModelIndex obj, QString name) {
    Model* item = getItem(obj);
    item->name = name;
}


void ModelList::insertDB(QVariant dataBase) {
	QSqlDatabase db = dataBase.value<QSqlDatabase>();
	QSqlQuery query0(db), query1(db), query2(db), query3(db), query4(db);
}

QJsonArray ModelList::getData(QModelIndex idx, QString t)
{
	QJsonArray data;
	Model* model = type(idx);
	if (model == nullptr)
		return QJsonArray();
	for (QString name : model->data[t].toObject().keys()) {
		QJsonObject d = model->data[t].toObject()[name].toObject();
		d.insert("Name", name);
		data.append(d);
	}
	return data;
}

void ModelList::editIcon(QModelIndex idx, QUrl path)
{
    Model* model = type(idx);
    if (!path.isEmpty()) {
        QImageReader reader(path.toLocalFile());
        QImage image;
        if (reader.read(&image)) {
            QByteArray byteArray;
            QBuffer buffer(&byteArray);
            buffer.open(QIODevice::WriteOnly);
            if (!image.save(&buffer, QImageReader::imageFormat(path.toLocalFile()))) {
                // 使用 QImageReader 检测到的格式
                qDebug() << "无法保存图片";
            }
            // 现在 byteArray 包含了图片的二进制数据
            model->data.insert("Icon", QString(byteArray.toBase64()));
        }
        else {
            qDebug() << "无法读取图片";
        }
    }
    else
    {
        model->data["Icon"] = "";
    }
}

void ModelList::editPort(QModelIndex idx, QJsonObject data)
{
	Model* model = type(idx);
	if (model == nullptr)
		return;
	QString name = data.value("Name").toString();
    data.remove(name);
    QJsonObject& d = model->data;
    QJsonObject ports = d.value("Ports").toObject();
    if (data.isEmpty()) {
        ports.remove(name);
    }
    else
    {
        ports.insert(name, data);
    }
    d.insert("Ports", ports);
}

void ModelList::editData(QModelIndex idx, QJsonObject data, QString t)
{
    QString name = data.value("Name").toString();
    data.remove("Name");
    Model* m = type(idx);
    QJsonObject& d = m->data;
    if (data.isEmpty()) {
        QJsonObject datas = d[t].toObject();
        datas.remove(name);
        d.insert(t, datas);
    }
    if (d.contains(t)) {
        QJsonObject datas = d[t].toObject();
        datas.insert(name, data);
        d.insert(t, datas);
    }
    else {
        d.insert(t, QJsonObject{ {name, data} });
    }
}

void ModelList::editDatas(QModelIndex idx, QJsonArray data, QString t)
{
    for (auto d : data) {
        editData(idx, d.toObject(), t);
    }
}

void ModelList::editPorts(QModelIndex idx, QJsonArray data)
{	
	Model* model = type(idx);
	for (auto p : data) {
		QJsonObject port = p.toObject();
		QString name = port.value(QLatin1String("Name")).toString();
		port.remove("Name");
		model->data["Ports"].toObject().insert(name, port);
	}
}
