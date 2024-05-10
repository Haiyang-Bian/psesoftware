#include "../include/DndTree.h"

DndTree::DndTree(QObject* parent) : QAbstractItemModel(parent)
{
    rootItem = new DndTreeItem;
}

QModelIndex DndTree::index(int row, int column, const QModelIndex& parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();
    DndTreeItem* parentItem = getItem(parent);
    auto childPtr = parentItem->subItems.at(row);
    if (childPtr) {
        return createIndex(row, column, childPtr);
    }
    else {
        return QModelIndex();
    }
}

QModelIndex DndTree::parent(const QModelIndex& index) const
{
    if (!index.isValid()) {
        return QModelIndex();
    }
    DndTreeItem* childItem = getItem(index);
    auto parentPtr = childItem->parentItem;
    if (!parentPtr || parentPtr == rootItem) {
        return QModelIndex();
    }
    return createIndex(parentPtr->row, 0, parentPtr);
}

int DndTree::rowCount(const QModelIndex& parent) const
{
    DndTreeItem* parentItem = getItem(parent);
    return parentItem->subItems.size();
}

int DndTree::columnCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
        return 1;
}

QVariant DndTree::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }
    DndTreeItem* item = getItem(index);
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

QHash<int, QByteArray> DndTree::roleNames() const
{
    QHash<int, QByteArray> names = QAbstractItemModel::roleNames();
    names.insert(QHash<int, QByteArray>{
        {NameRole, "name"},
        { TypeRole, "type" }
    });
    return names;
}

void DndTree::resetItems()
{
    beginResetModel();
    DndTreeItem* lv1{ new DndTreeItem }, * l2{ new DndTreeItem };
    lv1->parentItem = rootItem;
    rootItem->subItems.append(lv1);
    lv1->row = 0;
    lv1->name = "NewLib1";
    endResetModel();
}

DndTreeItem* DndTree::getItem(const QModelIndex& idx) const
{
    if (idx.isValid()) {
        DndTreeItem* item = static_cast<DndTreeItem*>(idx.internalPointer());
        if (item) {
            return item;
        }
    }
    return rootItem;
}

void DndTree::createItem(QModelIndex order, bool isFilter, QString name) {
    DndTreeItem* lv1{ new DndTreeItem };
    DndTreeItem* father = getItem(order);
    beginInsertRows(order, this->rowCount(order), this->rowCount(order));
    lv1->parentItem = father;
    lv1->row = this->rowCount(order);
    father->subItems << lv1;
    lv1->isFilter = isFilter;
    lv1->name = name;
    endInsertRows();
}

void DndTree::removeItem(QModelIndex order) {
    // 很遗憾这里不能使用QSharedPointer,否则会触发访问权限冲突的问题
    // 我并没有找到解决方法
    beginRemoveRows(this->parent(order), order.row(), order.row());
    DndTreeItem* father = getItem(parent(order));
    father->subItems[order.row()]->parentItem = nullptr;
    bool isFilter = father->subItems[order.row()]->isFilter;
    QList<DndTreeItem*> subItems = father->subItems[order.row()]->subItems;
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

void DndTree::moveItem(QModelIndex order, QModelIndex target) {
    DndTreeItem* s = getItem(order);
    DndTreeItem* t = getItem(target);
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

void DndTree::createLib(QString name) {
    beginInsertRows(QModelIndex(), rootItem->subItems.size(), rootItem->subItems.size());
    DndTreeItem* newLib{ new DndTreeItem };
    newLib->parentItem = rootItem;
    newLib->row = rootItem->subItems.size();
    newLib->name = name;
    rootItem->subItems << newLib;
    endInsertRows();
}

void DndTree::changeName(QModelIndex obj, QString name) {
    DndTreeItem* item = getItem(obj);
    item->name = name;
}
