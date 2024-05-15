#include "../include/LibTreeModel.h"
#include <qqmlengine.h>
#include <iostream>
#include <qjsondocument.h>

 LibTreeModel:: LibTreeModel(QObject* parent) : QAbstractItemModel(parent)
{
    rootItem = new LibModel;
}

QModelIndex  LibTreeModel::index(int row, int column, const QModelIndex& parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();
    LibModel* parentItem = getItem(parent);
    auto childPtr = parentItem->subItems.at(row);
    if (childPtr) {
        return createIndex(row, column, childPtr);
    }
    else {
        return QModelIndex();
    }
}

QModelIndex  LibTreeModel::parent(const QModelIndex& index) const
{
    if (!index.isValid()) {
        return QModelIndex();
    }
    LibModel* childItem = getItem(index);
    auto parentPtr = childItem->parentItem;
    if (!parentPtr || parentPtr == rootItem) {
        return QModelIndex();
    }
    return createIndex(parentPtr->row, 0, parentPtr);
}

int  LibTreeModel::rowCount(const QModelIndex& parent) const
{
    LibModel* parentItem = getItem(parent);
    return parentItem->subItems.size();
}

int  LibTreeModel::columnCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
        return 1;
}

QVariant  LibTreeModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    LibModel* item = getItem(index);
    if (role == Qt::DisplayRole) {
        //TreeView继承自TableView，所以可以通过不同的column来取单元格数据
        role = Qt::UserRole + index.column();
    }
    switch (role) {
    case NameRole: return item->name;
    case TypeRole: 
        if (item->models.isEmpty())
            return false;
        else
            return true;
    case ModelsRole: return item->models;
    default: break;
    }
    return QVariant();
}

QHash<int, QByteArray> LibTreeModel::roleNames() const
{
    QHash<int, QByteArray> names = QAbstractItemModel::roleNames();
    names.insert(QHash<int, QByteArray>{
        { NameRole, "name" },
        { TypeRole, "type" },
        { ModelsRole, "models" }
    });
    return names;
}

void  LibTreeModel::resetItems()
{
    if (rootItem->subItems.isEmpty()) {
        beginResetModel();
        LibModel* lv1{ new LibModel }, * l2{ new LibModel };
        lv1->parentItem = rootItem;
        rootItem->subItems.append(lv1);
        lv1->row = 0;
        lv1->name = "NewLib1";
        endResetModel();
    }
}

LibModel* LibTreeModel::getItem(const QModelIndex& idx) const
{
    if (idx.isValid()) {
        LibModel* item = static_cast<LibModel*>(idx.internalPointer());
        if (item) {
            return item;
        }
    }
    return rootItem;
}