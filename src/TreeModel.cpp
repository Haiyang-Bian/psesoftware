#include "../include/TreeModel.h"

MyTreeModel::MyTreeModel(QObject* parent)
    : QAbstractItemModel(parent), rootItem(new MyTreeItem)
{
}

QModelIndex MyTreeModel::index(int row, int column, const QModelIndex& parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();
    MyTreeItem* parentItem = getItem(parent);
    auto childPtr = parentItem->subItems.at(row);
    if (childPtr) {
        return createIndex(row, column, childPtr.get());
    }
    else {
        return QModelIndex();
    }
}

QModelIndex MyTreeModel::parent(const QModelIndex& index) const
{
    if (!index.isValid()) {
        return QModelIndex();
    }
    MyTreeItem* childItem = getItem(index);
    auto parentPtr = childItem->parentItem;
    if (!parentPtr || parentPtr == rootItem) {
        return QModelIndex();
    }
    return createIndex(parentPtr.get()->row, 0, parentPtr.get());
}

int MyTreeModel::rowCount(const QModelIndex& parent) const
{
    MyTreeItem* parentItem = getItem(parent);
    return parentItem->subItems.size();
}

int MyTreeModel::columnCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
        return 1;
}

QVariant MyTreeModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    MyTreeItem* item = getItem(index);
    if (role == Qt::DisplayRole) {
        //TreeView继承自TableView，所以可以通过不同的column来取单元格数据
        role = Qt::UserRole + index.column();
    }
    switch (role) {
    case NameRole: return item->name;
    default: break;
    }
    return QVariant();
}

QHash<int, QByteArray> MyTreeModel::roleNames() const
{
    QHash<int, QByteArray> names = QAbstractItemModel::roleNames();
    names.insert(QHash<int, QByteArray>{
        {NameRole, "name"}
    });
    return names;
}

void MyTreeModel::resetItems()
{
    beginResetModel();
    QSharedPointer<MyTreeItem> lv1{ new MyTreeItem };
    lv1->parentItem = rootItem;
    rootItem->subItems.append(lv1);
    lv1->row = 0;
    lv1->name = QString("Project_%1").arg(1);
    QList<QString> items;
    items.append("变量类型");
    items.append("连接类型");
    items.append("模型");
    items.append("过程");
    for (QList<QString>::iterator it = items.begin(); it != items.end(); it++)
    {
        QSharedPointer<MyTreeItem> lv2{ new MyTreeItem };
        lv2->parentItem = lv1;
        lv1->subItems.append(lv2);
        lv2->row = it - items.begin();
        lv2->name = *it;
    }
    endResetModel();
}

MyTreeItem* MyTreeModel::getItem(const QModelIndex& idx) const
{
    if (idx.isValid()) {
        MyTreeItem* item = static_cast<MyTreeItem*>(idx.internalPointer());
        if (item) {
            return item;
        }
    }
    return rootItem.get();
}

void MyTreeModel::createItem(QString name) {
    QSharedPointer<MyTreeItem> lv1{ new MyTreeItem };
    rootItem->subItems.append(lv1);
    beginInsertRows(QModelIndex(), 0, 0);
    lv1->parentItem = rootItem;
    lv1->row = this->rowCount();
    if (name == "")
        lv1->name = QString("Project_%1").arg(this->rowCount());
    else
        lv1->name = name;
    QList<QString> items;
    items.append("变量类型");
    items.append("连接类型");
    items.append("模型");
    items.append("过程");
    for (QList<QString>::iterator it = items.begin(); it != items.end(); it++)
    {
        QSharedPointer<MyTreeItem> lv2{ new MyTreeItem };
        lv2->parentItem = lv1;
        lv1->subItems.append(lv2);
        lv2->row = it - items.begin();
        lv2->name = *it;
    }
    endInsertRows();
}

void MyTreeModel::viewItem(int index, int type, QString name) {
    QSharedPointer<MyTreeItem> lv1{ new MyTreeItem };
    lv1->name = name;
    switch (type)
    {
    case 1:

    case 2:
    case 3:
    default:
        break;
    }
    rootItem->subItems.append(lv1);
    beginInsertRows(QModelIndex(), 0, 0);
    lv1->parentItem = rootItem;
    lv1->row = this->rowCount();
    lv1->name = QString("Project_%1").arg(this->rowCount());
    QList<QString> items;
    items.append("变量类型");
    items.append("连接类型");
    items.append("模型");
    items.append("过程");
    for (QList<QString>::iterator it = items.begin(); it != items.end(); it++)
    {
        QSharedPointer<MyTreeItem> lv2{ new MyTreeItem };
        lv2->parentItem = lv1;
        lv1->subItems.append(lv2);
        lv2->row = it - items.begin();
        lv2->name = *it;
    }
    endInsertRows();
}

int MyTreeModel::projectNumber() {
    return rootItem->subItems.size();
}