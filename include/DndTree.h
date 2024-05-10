#ifndef DNDTREE_H
#define DNDTREE_H

#pragma once
#include <QAbstractItemModel>
#include <qqml.h>
#include "DndControler.h"

//自定义树节点
struct DndTreeItem
{
    //节点属性
    QString name;
    QJsonObject data;
    DndControler dnd;
    bool isFilter = true;
    //节点位置
    int row;
    //父节点
    DndTreeItem* parentItem = nullptr;
    //子节点列表
    QList<DndTreeItem*> subItems;
};

class DndTree : public QAbstractItemModel
{
    Q_OBJECT
        QML_ELEMENT
private:
    enum RoleType
    {
        NameRole = Qt::UserRole,
        TypeRole
    };
public:
    explicit DndTree(QObject* parent = nullptr);
    ~DndTree(){}
    DndTree(const DndTree& tmd) {
        this->rootItem = tmd.rootItem;
    }

    //需要重写的基类接口
    QModelIndex index(int row, int column,
        const QModelIndex& parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex& index) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    int columnCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    inline DndTree& operator=(const DndTree& cao) {
        return const_cast<DndTree&>(cao);
    }

    //初始化数据
    Q_INVOKABLE void resetItems();
    Q_INVOKABLE void createItem(QModelIndex order, bool isFilter, QString name = "");
    Q_INVOKABLE void removeItem(QModelIndex order);
    Q_INVOKABLE void moveItem(QModelIndex order, QModelIndex target);
    Q_INVOKABLE void createLib(QString name);
    Q_INVOKABLE void changeName(QModelIndex obj, QString name);

private:
    DndTreeItem* getItem(const QModelIndex& idx) const;

private:
    //根节点
    DndTreeItem* rootItem;
};

#endif // DNDTREE_H
